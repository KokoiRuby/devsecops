## [Sealed-secret](https://github.com/bitnami-labs/sealed-secrets)

It encrypts your Secret into a SealedSecret, which *is* safe to store - even inside a public repository.

:package: [kubeseal](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#kubeseal)

**Scope**

- **strict**: CR & Secret share the same name & ns, any touch on CR will lead decryption failure.
- **[namespace|cluster]-wide**: namespaced or global (re-name-able)

![sealed-secret](Readme.assets/sealed-secret.png)

### **Best Practice**

- Keep private key in `sealed-secrets-keycschm secret` secret somewhere else safe.
- Backup `sealed-secrets-keycschm secret` secret manifest.
- Own [cert.](https://github.com/bitnami-labs/sealed-secrets/blob/main/docs/bring-your-own-certificates.md)

### Hands-on

#### Demo#1

> Create sealed secret

```bash
# create sealed secret
kubeseal \
	-f manifest/secret-demo1.yaml \
	-w manifest/sealed-secret-demo1.yaml \
	--scope cluster-wide

# apply sealed secret
kubectl apply -f manifest/sealed-secret-demo1.yaml

# chk
kubectl get secret my-secret-demo1 -o yaml
```

#### Demo#2

> Manage existing secrets

```bash
# create secret first
kubectl apply -f manifest/secret-demo2.yaml

# patch
kubectl patch secret my-secret-demo2 -p '{"metadata":{"annotations":{"sealedsecrets.bitnami.com/managed":"true"}}}'

# create sealed secret
kubeseal \
	-f manifest/secret-demo2.yaml \
	-w manifest/sealed-secret-demo2.yaml \
	--scope cluster-wide

# re-create sealed-secret cr
kubectl apply -f manifest/sealed-secret-demo2.yaml
```
