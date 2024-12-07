## [Submarine](https://submariner.io/)

It enables direct networking between Pods and **Services** across Kubernetes clusters = **"Flattening"**.

### [Architecture](https://submariner.io/getting-started/architecture/)

- Broker cluster is for cross-cluster service discovery.
- Clusters communicate with each other by IPsec tunnel.
- Service[Export|Import] CRDs.

![Submariner Architecture](https://submariner.io/images/submariner/architecture.jpg)

### Hands-on

> Note: you need to go through Karmada tutorial first

> Note: cluster pod & service cider must not overlap to each other.

#### Demo#1

> Service discovery btw clusters

[Install](https://submariner.io/operations/deployment/subctl/) subctl.

Install submarine in karmada cluster.

```bash
subctl deploy-broker --kubeconfig ./config.yaml
```

Label cluster-1 & cluster-2.

```bash
kubectl --kubeconfig ./config1.yaml label node cluster-1 submariner.io/gateway=true
kubectl --kubeconfig ./config2.yaml label node cluster-2 submariner.io/gateway=true
```

Join cluster-1 & cluster-2.

```bash
subctl join --kubeconfig ./config1.yaml broker-info.subm --natt=false --clusterid=cluster-1
subctl join --kubeconfig ./config2.yaml broker-info.subm --natt=false --clusterid=cluster-2
```

Check.

```bash
kubectl -n submariner-k8s-broker get clusters.submariner.io --kubeconfig ./config.yaml
```

Propagate CRDs to cluster-1 & cluster-2.

```bash
kubectl apply -f ../../submarine/manifest/demo1/cluster-propagation-policy.yaml
```

Deploy demo app in cluster-1.

```bash
kubectl apply -f ../../submarine/manifest/demo1/app.yaml
```

Check.

```bash
kubectl get service
```

Export from cluster-1 then import into cluster-2.

```bash
kubectl apply -f ../../submarine/manifest/demo1/service-export.yaml
kubectl apply -f ../../submarine/manifest/demo1/service-import.yaml
```

Check.

```bash
kubectl get svc
```



