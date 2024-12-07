## [karmada](https://karmada.io/docs/)

A Kubernetes management system that enables you to run your cloud-native applications across multiple Kubernetes clusters and clouds。

### Architecture

- Karmada API Server: is the REST endpoint all other components talk to.
- **Karmada Scheduler**: makes scheduling decisions across these clusters based on defined policies and resource availability.
- **ETCD**: stores the Karmada API objects.
- **Karmada Controller Manager**: watch Karmada objects and talk to the underlying clusters' API servers to create Kubernetes resources.
  - **Cluster**: attaches Kubernetes clusters to Karmada for managing the lifecycle of the clusters.
  - **Policy**: selects a group of resources matching the resourceSelector and creates **ResourceBinding** with each single object.
  - **Binding**: creates **Work** corresponding to each cluster with a single resource manifest.
  - **Execution**: distributes the resources to member clusters.

![Architecture](https://github.com/karmada-io/karmada/raw/master/docs/images/architecture.png)

### Integration with ArgoCD



### Hands-on

#### Demo#1

> **Push** (when cluster is publicly **acecssible**) vs. **Agent** (when cluster is publicly **inacecssible**)

[Install](https://karmada.io/docs/installation/) karmadactl locally.

Initiliaze in karmada cluster.

```bash
export KUBECONFIG=./config.yaml
export ip="<ip>"

karmadactl init \
	--karmada-data ./data \
	--karmada-pki ./data \
	--karmada-apiserver-advertise-address ${ip} \
	--cert-external-ip ${ip}
```

Add clusters.

```bash
karmadactl join cluster-1 \
	--kubeconfig ./data/karmada-apiserver.config \
	--cluster-kubeconfig=config1.yaml

karmadactl join cluster-2 \
	--kubeconfig ./data/karmada-apiserver.config \
	--cluster-kubeconfig=config2.yaml
```

Check.

```bash
export KUBECONFIG="$(pwd)/data/karmada-apiserver.config" && kubectl get cluster
```

#### Demo#2

> Scheduling

Apply propagation policy & nginx deployment.

```bash
kubectl apply -f ../manifest/demo2/propagationpolicy.yaml
kubectl apply -f ../manifest/demo2/deployment-nginx.yaml
```

Check

```bash
karmadactl get deploy

# ok
karmadactl get pod --operation-scope=members -l app=nginx
# nok since info will no sync to karmada cluster
kubectl get pod 
```

Schedule pod to cluster-2 only.

```bash
kubectl delete -f ../manifest/demo2/propagationpolicy.yaml
kubectl apply -f ../manifest/demo2/propagationpolicy-cluster2-only.yaml
```

Check

```bash
karmadactl get deploy
karmadactl get pod --operation-scope=members -l app=nginx
```

Label cluster.

```bash
kubectl label cluster cluster-1 location=shangai
kubectl label cluster cluster-2 location=hongkong
```

Schedule pod to cluster1 with label location=shanghai.

```bas
kubectl apply -f ../manifest/demo2/propagationpolicy-cluster-label.yaml
```

Check

```bash
karmadactl get deploy
karmadactl get pod --operation-scope=members -l app=nginx
```

Schedule pod to clusters by weight.

```bas
kubectl apply -f ../manifest/demo2/propagationpolicy-weight.yaml
```

Check

```bash
karmadactl get deploy
karmadactl get pod --operation-scope=members -l app=nginx
```

#### Demo#3

> HPA

> Note: you need to go through submarine tutorial first.

Install karmada-metrics-adapter in karmada cluster.

```bash
../manifest/demo3/deploy-metrics-adapter.sh ./config.yaml cluster.local \
	./data/karmada-apiserver.config karmada-apiserver
```

Deploy demo app.

```bash
export KUBECONFIG=./data/karmada-apiserver.config && kubectl apply -f ../manifest/demo3/app.yaml
```

Deploy FederatedHPA CRD.

```bash
kubectl apply -f ../manifest/demo3/federatedHPA.yaml
```

Check.

```bash
kubectl get fhpa
```

Export demo app in from cluster-1 then import into cluster-2.

```bash
kubectl apply -f ../manifest/demo3/service-export.yaml
kubectl apply -f ../manifest/demo3/service-import.yaml
```

#### Demo#4

> [Ingress](https://karmada.io/docs/userguide/service/multi-cluster-ingress/)

(TODO)
