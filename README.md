```bash
# env
export KUBECONFIG=./config.yaml
```

### sealed-secrets

```bash
# create sealed secret
kubeseal \
	-f helm_sealed_secret/secret-cloudflare-token.yaml \
	-w helm_sealed_secret/sealed-secret-cloudflare-token.yaml \
	--scope cluster-wide
```

```bash
# apply sealed secret
kubectl apply -f helm_sealed_secret/sealed-secret-cloudflare-token.yaml
```

```bash
# chk sealed secret
kubectl get secret -n cert-manager cloudflare-api-token
```

### cert-manager

```bash
# create cluster issuer
kubectl apply -f helm_cert_manager/cluster-issuer.yaml

# or namespaced
kubectl apply -f helm_harbor/issuer.yaml
```

```bash
# create cert
kubectl apply -f helm_harbor/certificate.yaml
```

### clean-up

```bash
terraform state rm helm_release.cert-manager
terraform state rm helm_release.harbor
terraform state rm helm_release.ingress-nginx
terraform state rm helm_release.sealed-secrets
terraform state rm "module.k3s"
terraform destroy --auto-approve
```

### TODO
