## DevSecOps

### Prerequisite



### Deploy

```bash
cd iac && terraform apply
```







```bash
# env
export KUBECONFIG=./config.yaml
```

### Sonarqube

```bash
kubectl apply -f helm_sonarqube/secret-sonar-token.yaml
```

### clean-up

```bash
terraform state rm helm_release.cert-manager
terraform state rm helm_release.harbor
terraform state rm helm_release.ingress-nginx
terraform state rm helm_release.sealed-secrets
terraform state rm helm_release.jenkins
terraform state rm helm_release.sonarqube
terraform state rm helm_release.argo-cd
terraform state rm "module.k3s"
terraform destroy --auto-approve
```

### TODO
