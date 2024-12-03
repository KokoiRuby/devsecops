## Admission [Webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)

> Resource → **(pre)** → Cluster → (post) → Monitoring event → Alert

In addition to [compiled-in admission plugins](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/), admission plugins can be developed as ext. and run as **webhooks** configured at **runtime**. 

Admission webhooks are **HTTP callbacks** that receive admission requests.

**MutatingAdmissionWebhook** can modify objects sent to the API server to enforce custom defaults. (Serial)

**ValidatingAdmissionWebhook** can reject requests to enforce custom policies. (Parallel)

![Admission Controller Phases](https://kubernetes.io/images/blog/2019-03-21-a-guide-to-kubernetes-admission-controllers/admission-controller-phases.png)



### Experimenting with admission webhooks

#### Prerequisite

Ensure that **MutatingAdmissionWebhook** and **ValidatingAdmissionWebhook** admission controllers are [enabled](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#is-there-a-recommended-set-of-admission-controllers-to-use).

```bash
# kube-apiserver flag
--enable-admission-plugins
--disable-admission-plugins
```

```yaml
# kind
cat > kind-cluster-config.yaml << EOF | kind create cluster --config -
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: admission-control   # here
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
        extraArgs:
          enable-admission-plugins: NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook 
EOF
```

Ensure that the `admissionregistration.k8s.io/v1` API is enabled.

```bash
kubectl api-resources --api-group=admissionregistration.k8s.io
```

#### Write an admission webhook server

The webhook handles the `AdmissionReview` [request](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#request) sent by the API servers & sends back `AdmissionReview` [response](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#response) in the same version.

To [authenticate](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#authenticate-apiservers) API servers.

```yaml
# API server (as client) is creating a pod named example-pod 
# with container named example-container using nginx image in default ns
kind: AdmissionReview
apiVersion: admission.k8s.io/v1
request:
  uid: "12345678-1234-5678-1234-567812345678"
  kind:
    group: ""
    version: "v1"
    kind: "Pod"
  resource:
    group: ""
    version: "v1"
    resource: "pods"
  name: "example-pod"
  namespace: "default"
  operation: "CREATE"
  userInfo:
    username: "system:serviceaccount:default:default"
    uid: "abcdef12-3456-7890-abcd-ef1234567890"
    groups:
      - "system:serviceaccounts"
      - "system:authenticated"
  object:
    metadata:
      name: "example-pod"
      namespace: "default"
      labels:
        app: "example"
    spec:
      containers:
        - name: "example-container"
          image: "nginx"
```

```yaml
response:
  uid: "12345678-1234-5678-1234-567812345678"
  allowed: true
  status:
    message: "Pod creation allowed"
```

```yaml
response:
  uid: "12345678-1234-5678-1234-567812345678"
  allowed: false
  status:
    message: "Pods with the label 'app: example' are not allowed."

```

#### Deploy the admission webhook service

The webhook server is deployed as `apps/v1/Deployment`.

#### Configure admission webhooks on the fly

Via [MutatingWebhookConfiguration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#mutatingwebhookconfiguration-v1-admissionregistration-k8s-io) or [ValidatingWebhookConfiguration](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#validatingwebhookconfiguration-v1-admissionregistration-k8s-io).

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: example-mutating-webhook
webhooks:
  - name: example.webhook.com
    clientConfig:
      service:
        name: example-webhook-service
        namespace: default
        path: /mutate
      caBundle: <CA_BUNDLE>  # Base64 encoded CA certificate to verify API server
    rules:
      - operations: ["CREATE", "UPDATE"]     # Operations to intercept
        apiGroups: ["*"]                     # All API groups
        apiVersions: ["*"]                   # All API versions
        resources: ["pods"]                  # Resource types to intercept
    admissionReviewVersions: ["v1"]          # Supported admission review versions
    sideEffects: None                        # Indicates side effects of the webhook
    timeoutSeconds: 5                        # Timeout for the webhook call
```

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: example-validating-webhook
webhooks:
  - name: example.webhook.com
    clientConfig:
      service:
        name: example-webhook-service
        namespace: default
        path: /validate
      caBundle: <CA_BUNDLE>  # Base64 encoded CA certificate to verify API server
    rules:
      - operations: ["CREATE", "UPDATE"]     # Operations to intercept
        apiGroups: ["*"]                     # All API groups
        apiVersions: ["*"]                   # All API versions
        resources: ["pods"]                  # Resource types to intercept
    admissionReviewVersions: ["v1"]          # Supported admission review versions
    sideEffects: None                        # Indicates side effects of the webhook
    timeoutSeconds: 5                        # Timeout for the webhook call
```

### [Kyverno](https://release-1-12-0.kyverno.io/docs/introduction/)

:cry: Need to touch source whenever we want to add admission control logic.

:smile: **Policy-as-Code (PaC)** - declarative YAML resources.

Kyverno [policies](https://kyverno.io/policies/) can **validate, mutate, generate, and cleanup** any Kubernetes resource, including custom resources.

![Kyverno Architecture](https://release-1-12-0.kyverno.io/images/kyverno-architecture.png)

![Kyverno Policy](https://kyverno.io/images/Kyverno-Policy-Structure.png)

### Hands-on

#### [Demo#1](https://github.com/stackrox/admission-controller-webhook-demo)

> A mutating admission webhook enforces more secure defaults for running containers as non-root user by setting `runAsNonRoot` to true and user ID default to `1234` in `securityContext`.

Code review

```go
// it parses the HTTP request for an admission controller webhook
// and delegate admission control logic to the given admitFunc
func doServeAdmitFunc(w http.ResponseWriter, r *http.Request, admit admitFunc) ([]byte, error)

// a callback for admission control logic
type admitFunc func(*admission.AdmissionRequest) ([]patchOperation, error)
```

```go
// 1. read body out from http req
body, err := ioutil.ReadAll(r.Body)
```

```go
// 2. un-marshal body (JSON) to admissionReviewReq
var admissionReviewReq admission.AdmissionReview
universalDeserializer.Decode(body, nil, &admissionReviewReq)

// AdmissionReview describes an admission review request/response.
type AdmissionReview struct {
	metav1.TypeMeta `json:",inline"`
	// Request describes the attributes for the admission request.
	// +optional
	Request *AdmissionRequest `json:"request,omitempty" protobuf:"bytes,1,opt,name=request"`
	// Response describes the attributes for the admission response.
	// +optional
	Response *AdmissionResponse `json:"response,omitempty" protobuf:"bytes,2,opt,name=response"`
}
```

```go
// 3. construct the AdmissionReview response.
admissionReviewResponse := admission.AdmissionReview{ ... }
```

```go
// 4. admit & return patch
// admit is a callback in "admitFunc" type
patchOps, err = admit(admissionReviewReq.Request)
```

```go
// 5. patch if admit pass
patchBytes, err := json.Marshal(patchOps)
admissionReviewResponse.Response.Patch = patchBytes
```

```go
// 6. serialize (to JSON) & return to API server
bytes, err := json.Marshal(&admissionReviewResponse)
```

Trace admitFunc.

```go
// main.go
mux.Handle("/mutate", admitFuncHandler(applySecurityDefaults))
// ↑ 
func admitFuncHandler(admit admitFunc)
// ↑ 
func serveAdmitFunc(w http.ResponseWriter, r *http.Request, admit admitFunc)
// ↑
func doServeAdmitFunc(w http.ResponseWriter, r *http.Request, admit admitFunc)
```

```go
// implements the logic of admission controller webhook.
func applySecurityDefaults(req *admission.AdmissionRequest) ([]patchOperation, error)
```

```go
if pod.Spec.SecurityContext != nil {
	runAsNonRoot = pod.Spec.SecurityContext.RunAsNonRoot
	runAsUser = pod.Spec.SecurityContext.RunAsUser
}

if runAsNonRoot == nil {
    patches = append(patches, patchOperation{
        Op:    "add",
        Path:  "/spec/securityContext/runAsNonRoot",
        Value: runAsUser == nil || *runAsUser != 0,
    })

    if runAsUser == nil {
        patches = append(patches, patchOperation{
            Op:    "add",
            Path:  "/spec/securityContext/runAsUser",
            Value: 1234,
        })
    }
} else if *runAsNonRoot && (runAsUser != nil && *runAsUser == 0) {
    // Make sure that the settings are not contradictory,
    // and fail the object creation if they are.
    return nil, errors.New("runAsNonRoot specified, but runAsUser set to 0 (the root user)")
}

```

Manifest

```yaml
# deployment
containers:
  - name: server
    image: stackrox/admission-controller-webhook-demo:latest
    imagePullPolicy: Always
    ports:
      - containerPort: 8443
        name: webhook-api
    volumeMounts:
      - name: webhook-tls-certs
        mountPath: /run/secrets/tls
        readOnly: true
---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration
metadata:
  name: demo-webhook
webhooks:
  - name: webhook-server.webhook-demo.svc
    sideEffects: None
    admissionReviewVersions: ["v1", "v1beta1"]
    clientConfig:
      # to
      service:
        name: webhook-server
        namespace: webhook-demo
        path: "/mutate"
      caBundle: ${CA_PEM_B64}
    # intercept when 
    rules:
      - operations: [ "CREATE" ]
        apiGroups: [""]
        apiVersions: ["v1"]
        resources: ["pods"]
```

Deploy

```bash
# create self-signed ca & webhook server
./deploy.sh
```

Verify

```bash
# create
kubectl create -f examples/pod-with-defaults.yaml

# chk & notice security ctx is added
kubectl logs pod-with-defaults
kubectl describe po pod-with-defaults
```

```go
// create
kubectl create -f examples/pod-with-override.yaml
```

```go
// chk & notice security ctx is added
kubectl logs pod-with-override
kubectl describe po pod-with-override
```

```go
// create
kubectl create -f examples/pod-with-conflict.yaml
```

#### Demo#2

> A validating admission webhook that only accepts pods with specific labels in a ns with specific annotation

Code Review

```go
// handlers.go

// ns annotation constraint
if !ok {
    app.infoLog.Printf(
        "skipping validation of the Pod %s in namespace %s", 
        pod.Name, 
        pod.Namespace,
    )
    requestAllowed = true
    respMsg = "skipping validation as annotationKey " + app.cfg.Annotation + " is missing or set to false"
}


// chk if pod had labels
if val, ok := pod.ObjectMeta.Labels[app.cfg.Label]; ok {
    if val != "" {
        requestAllowed = true
        respMsg = "Allowed as label " + app.cfg.Label + " is present in the Pod"
    }
    app.infoLog.Printf(
        "Allowed Pod %v in namespace %v because label %v is present", 
        pod.Name, 
        pod.Namespace, 
        app.cfg.Label,
    )
}

output := admissionv1.AdmissionReview{
    Response: &admissionv1.AdmissionResponse{
        UID:     input.Request.UID,
        // set
        Allowed: requestAllowed,
        Result: &metav1.Status{
            Message: respMsg,
        },
    },
}
```

```go
// app.go
type application struct {
	errorLog *log.Logger
	infoLog  *log.Logger
	cfg      *envConfig
	client   kubernetes.Interface
}

type envConfig struct {
	CertPath   string `env:"CERT_PATH" envDefault:"/source/cert.pem"`
	KeyPath    string `env:"KEY_PATH" envDefault:"/source/key.pem"`
	Port       int    `env:"PORT" envDefault:"3000"`
	Annotation string `env:"ANNOTATION" envDefault:"example.com/validate"`
	Label      string `env:"LABEL" envDefault:"owner"`
}
```

Deploy

```bash
kubectl apply -f manifests/validating/secret-ca.yaml
kubectl apply -f manifests/validating/webhook.yaml
kubectl apply -f manifests/validating/validating-webhook-configuration.yaml
```

Verify

```bash
kubectl create ns validating-webhook-test

# annotate
kubectl annotate ns validating-webhook-test example.com/validate=true

# deny 
kubectl apply -f manifests/validating/pod-denied.yaml -n validating-webhook-test

# allow
kubectl apply -f manifests/validating/pod-allow.yaml -n validating-webhook-test
```

#### Demo#3

> Allow deployment with a specific label

[Install](https://kyverno.io/docs/installation/methods/) kyverno.

Deploy cluster policy.

```bash
kubectl apply -f manifests/kyverno/clusterpolicy-require-label.yaml

# allow
kubectl apply -f manifests/kyverno/deploy-allow-label.yaml

# deny
kubectl apply -f manifests/kyverno/deploy-deny-no-label.yaml
```

