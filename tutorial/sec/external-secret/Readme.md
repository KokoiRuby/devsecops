#### [External-secret](https://external-secrets.io/main/) + [Vault](https://www.vaultproject.io/)

**External Secrets Operator** is a Kubernetes operator that integrates external secret management systems.

The operator reads information from external APIs and automatically injects the values into a [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/).

![high-level](https://external-secrets.io/latest/pictures/diagrams-high-level-simple.png)

### Hands-on

#### Demo#1

> Create a secret by Vault

[Install](https://developer.hashicorp.com/vault/docs/platform/k8s/helm) vault first then setup vault.

```bash
# port-forwarding
kubectl port-forward svc/vault 8200:8200

# export env
export VAULT_ADDR='http://127.0.0.1:8200'

# init
vault operator init

# unseal
vault operator unseal <token>
```

Create a policy named "example" on [gui](http://127.0.0.1:8200) (root token).

```json
path "*" {
  capabilities = ["read", "list"]
}
```

![image-20241202155759556](Readme.assets/image-20241202155759556.png)

Enable `Username & Password` authentication method.

![image-20241202155906027](Readme.assets/image-20241202155906027.png)

Create a user example/example, and select policy just created.

![image-20241202160005654](Readme.assets/image-20241202160005654.png)

![image-20241202160038537](Readme.assets/image-20241202160038537.png)

Create a K/V secret engine named "k8s".

![image-20241202160153575](Readme.assets/image-20241202160153575.png)

Create a secret named "example" given secret data.

![image-20241202160309090](Readme.assets/image-20241202160309090.png)

Logout & login by newly created user.

![image-20241202160454194](Readme.assets/image-20241202160454194.png)

Get user token.

![image-20241202160542879](Readme.assets/image-20241202160542879.png)

Create vault token secret.

```yaml
kubectl create secret generic vault-token \
--from-literal=token=BLOCKED \
-n external-secrets
```

Create cluster secret store.

```yaml
kubectl apply -f manifest/clustersecretstore-demo1.yaml

# chk
kubectl get css
```

Create external secret.

```bash
kubectl apply -f manifest/externalsecrets-demo1.yaml
```

Check created secret.

```bash
kubectl get secret my-secret -n external-secrets -o yaml
```

#### Demo#2

> Push secret to secret store

![PushSecret](https://external-secrets.io/latest/pictures/diagrams-pushsecret-basic.png)

Create secret.

```bash
kubectl apply -f manifest/secret-demo2.yaml
```

Create push secret.

```bash
kubectl apply -f manifest/pushsecret-demo2.yaml
```
