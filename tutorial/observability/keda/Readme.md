## [KEDA](https://keda.sh/)

:cry: Prometheus adapter is not configuration-friendly.

:smile: KEDA, a [Kubernetes](https://kubernetes.io/)-based **Event Driven** Autoscaler.

- It supports **external metrics and events** as HPA scaling metrics (e.g., MQ, Redis, Prometheus).
- It contains built-in dozens of [scalers](https://keda.sh/docs/2.16/scalers/) that support commonly used scaling methods not natively supported by HPA.
  - Cron
  - RabbitMQ
  - HTTP

### Architecture

- **ScaledObject**: describes the relationship between event sources (external metrics) and workloads.
- **Scaler**: connects to external components and queries metrics.
- **Controller**: generates HPA objects based on the ScaledObject.
- **Metrics Adapter** : provides external metrics to the HPA.

### Hands-on

> Note: you need to go through Prometheus demos first.

#### Demo#1

> Note: make sure you have installed in keda, see more in `/iac/helm_prometheus.tf`.

```bash
# similarly, KEDA registers apiservice `external.metrics.k8s.io` to aggregation in API Server.
kubectl get apiservices | grep external.metrics
```

Create scaled object.

```bash
kubectl apply -f manifest/scaledobject-demo1.yaml
```

Trigger errors.

```bash
end=$((SECONDS+30))  # Set the end time to 30 seconds from now
while [ $SECONDS -lt $end ]; do
    curl http://prometheus-metrics-app.devsecops.yukanyan.us.kg/api/error
    sleep 0.5  # Optional: wait for 0.5 second between requests
done
```

Verify.

```bash
kubectl get hpa
kubectl get po

# where namespace is default, externalMetricNames is response_status, scaledobjectName is prometheus-metrics
kubectl get --raw "/apis/external.metrics.k8s.io/v1beta1/namespaces/${namespace}/${externalMetricNames}?labelSelector=scaledobject.keda.sh/name=${scaledobjectName}
```

