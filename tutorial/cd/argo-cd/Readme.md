## ArgoCD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. [CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

The Application CRD is the Kubernetes resource object representing **a deployed application instance** in an environment.

Sync [options](https://argo-cd.readthedocs.io/en/latest/user-guide/sync-options/) via annotations.

[Image Updater](https://argocd-image-updater.readthedocs.io/en/stable/) via [annotations](https://argocd-image-updater.readthedocs.io/en/stable/configuration/images/) - **Registry pull secret is required**. (modify `values.yaml` in app def repo won't trigger sync)

Webhook → GitHub

### [GitOps](https://about.gitlab.com/topics/gitops/)

A continuous delivery approach that uses **Git as the single source of truth** for both infra (IaC) & app def (manifest/helm/kustomize).

Check diff = current vs. desired state then drive to desired state.

### Hands-on

> Demo app src  [repository](https://github.com/KokoiRuby/devsecops-demo-app)
>
> Demo app helm [repository](https://github.com/KokoiRuby/devsecops-demo-app-helm)

#### Demo#1

![gitops](Readme.assets/gitops.png)

Upload images to harbor first.

```bash
# login
docker login harbor.devsecops.yukanyan.us.kg -u admin -p admin
```

```bash
# tag
docker tag <image_hash> harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.1.0
docker tag <image_hash> harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:v0.1.0
```

```bash
# push
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.1.0
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:v0.1.0
```

Check on harbor dashboard.

![image-20241201083658310](Readme.assets/image-20241201083658310.png)

![image-20241201083713630](Readme.assets/image-20241201083713630.png)

Go to tutorial directory & export kubeconfig env.

```bash
cd tutorial/cd/argo-cd
export KUBECONFIG=../../../iac/config.yaml
```

Copy demo values.yaml under to demo app helm repository.

![image-20241201091532593](Readme.assets/image-20241201091532593.png)

Add, Commit & Push.

```bash
git add .
git commit -m "argocd demo1"
git push -u origin main
```

Check "Repositories" in argocd dashboard. You would see a pre-added entry which was created by a secret during iac phase.

![image-20241201094858608](Readme.assets/image-20241201094858608.png)

![image-20241201094907472](Readme.assets/image-20241201094907472.png)

You might also try argo cli.

```bash
# loging
argocd login argocd.devsecops.yukanyan.us.kg

# list repo
argocd repo list
```

Then apply argocd application.

```bash
kubectl apply -f manifest/demo1-application.yaml
```

Check on argocd dashboard.

![image-20241201095138518](Readme.assets/image-20241201095138518.png)

![image-20241201095202876](Readme.assets/image-20241201095202876.png)

Verify URL.

- http://demo-app-dev.devsecops.yukanyan.us.kg/foo

- http://demo-app-dev.devsecops.yukanyan.us.kg/bar

Modify `demo1-values.yaml` in demo app helm repo. Add, Commit & Push again.

```yaml
foo:
  replicaCount: 2

bar:
  replicaCount: 2
```

```bash
git add .
git commit -m "argocd demo1 replica++"
git push -u origin main
```

Check on argocd dashboard.

![image-20241201095549693](Readme.assets/image-20241201095549693.png)

![image-20241201095555538](Readme.assets/image-20241201095555538.png)

In the end, rollback & prepare for the next demo.

```bash
kubectl delete -f manifest/demo1-application.yaml
```

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### Demo#2

#### Demo#3

#### demo#4

#### demo#5

#### demo#6
