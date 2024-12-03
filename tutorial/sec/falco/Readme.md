## [Falco](https://falco.org/docs/)

> Resource → (pre) → Cluster → **(post)** → Monitoring event → Alert

A cloud native security tool that provides **runtime security** across hosts, containers, Kubernetes, and cloud environments.

It uses **syscalls** to monitor a system's activity, by:

- Parsing the Linux syscalls from the kernel at runtime
- Asserting the stream against a powerful rules engine
- Alerting when a rule is violated

![k8s_audit_falco](https://www.ebpf.top/post/hello_falco/imgs/k8s_audit_falco.png)

### Rules

[Rules](https://falco.org/docs/rules) are the conditions under which an alert should be generated.

**Event level** in production:

1. shell cmd
2. ssh
3. user & pwd
4. sudo
5. db dump
6. vpn
7. cronjob
8. log
9. kernel module

### Integration with ArgoCD

![falco-argocd](Readme.assets/falco-argocd.png)

### Arch

**Falco**: provides a gRPC service for frontend interface connectivity and data collection.

**Rule Engine**: parses various YAML rules defined in Falco into the rule engine.

**libsinsp**: gathers and supplements information from low-level events reported by libscap, then sends to Rule Engine for filtering.

**libscap**: provides functionality for setting capture control parameters, saving files, and collecting operating system-level states.



![libs_to_cncf_arch](https://www.ebpf.top/post/hello_falco/imgs/libs_to_cncf_arch.png)

### Hands-on

#### Demo#1

[Install](https://falco.org/docs/setup/kubernetes/) falco then run alpine pod.

```bash
kubectl run alpine --image alpine -- sh -c "sleep infinity"
```

Exec cmd.

```bash
kubectl exec -it alpine -- sh -c "uptime"
```

Check falco log.

```bash
kubectl logs -l app.kubernetes.io/name=falco -n falco -c falco | grep Notice

# http://localhost:2802
kubectl port-forward svc/falco-falcosidekick-ui 2802:2802 -n falco
```

