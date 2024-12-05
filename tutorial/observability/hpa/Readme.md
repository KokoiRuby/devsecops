## [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

*HorizontalPodAutoscaler* automatically updates a workload resource with the aim of automatically scaling the workload to match demand.

The hpa **controller**, running in [control plane](https://kubernetes.io/docs/reference/glossary/?all=true#term-control-plane), periodically adjusts the desired scale of its target to match observed **metrics (cpu/mem)**.

The interval (15s) is set by the `--horizontal-pod-autoscaler-sync-period` parameter to the [`kube-controller-manager`](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/).

### Alogrithm

If the current metric value is `200m`, and the desired value is `100m`, the number of replicas will be doubled.

If the current value is instead `50m`, you'll halve the number of replicas

```
desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]
```

### Principle

1. Metrics-server registers **APIService** into **aggregator** in API Server.
2. The metrics api call (from hpa) will be forwarded to `metrics-server` service in `kube-system` namespace.

```bash
kubectl get apiservices | grep metric
```

```yaml
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
    port: 443
  version: v1beta1
  versionPriority: 100
```

```bash
# query cpu & mem
/apis/metrics.k8s.io/v1beta1/pods?labelSelector=key=value

# or
kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods\?labelSelector=app=key=value | jq
```

### With Prometheus



### Hands-on

> Note: you need to go through Prometheus demos first.

#### Demo#1

