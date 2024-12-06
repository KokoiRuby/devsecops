## Multi-cluster

*Multicloud* is when an organization uses cloud computing services from **at least two cloud providers** to run their applications.

The keys are: **multi-cluster management** & **scheduling**.

:smile:

- No single-cluster scaling issues
- No service availability issues

:cry:

- Hard to manage
- Cost ↑

Solution

~~[kubefed](https://github.com/kubernetes-retired/kubefed) (archived)~~

- Inconvenient to use
  - Existing resources need to be redefined
  - Compatibility issues between Federated Template API version and K8s native API version
- Cross-cluster service discovery
- No clear GA path; API maturity unclear

```yaml
apiVersion: kubefed.io/v1beta1
kind: FederatedDeployment  # Federated CRD
metadata:
  name: test-deployment
  namespace: test-namespace
spec:
  template:
    # ... 
  placement:
    clusters:
      - name: cluster1
      - name: cluster2
  overrides: 
    - clusterName: cluster2
      clusterOverrides:
        - path: "/spec/replicas"
          value: 5
```

[open-cluster-management](https://github.com/open-cluster-management-io/ocm)

- ManifestWork unifies the CRD objects for multi-cluster deployment and **declare** native gvk.

```yaml
apiVersion: work.open-cluster-management.io/v1
kind: ManifestWork
metadata:
  namespace: cluster1
spec:
  workload:
    manifests:
      # reference gvk
      - apiVersion: apps/v1  
        kind: Deployment
        spec:
```

[karmada](https://github.com/karmada-io/karmada)

- Policy defines scheduling behavior by resource selectors which **reference** native gvk.

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: example-policy
spec:
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
  placement:
    clusterAffinity:
      clusterNames:
        - member1
```