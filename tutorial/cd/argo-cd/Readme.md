## ArgoCD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes. [CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

The Application CRD is the Kubernetes resource object representing **a deployed application instance** in an environment.

### [GitOps](https://about.gitlab.com/topics/gitops/)

A continuous delivery approach that uses **Git as the single source of truth** for both infra (IaC) & app def (manifest/helm/kustomize). Check diff = current vs. desired state then drive to desired state.

![gitops](Readme.assets/gitops.png)

### Sync

> Reconcile every 3 min by default

Triggers:

1. Modify application definition (helm) repo manually.
2. Modify application definition (helm) repo by CI pipeline, or create a separate pipeline to modify repo automatically. (tag as input)

Sync [options](https://argo-cd.readthedocs.io/en/latest/user-guide/sync-options/) via annotations.



![trigger](Readme.assets/trigger.png)

### Image Updater

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

> Create & sync dev env by creating an argocd application.

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

Add, Commit & Push.

```bash
git add .
git commit -m "argocd demo1"
git push -u origin main
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

> Update image tag by Jenkins pipeline.

Create a pipeline on jenkins dashboard.

![image-20241201134323341](Readme.assets/image-20241201134323341.png)

Copy content of `Jenkinsfile-demo2` into.

![image-20241201134545336](Readme.assets/image-20241201134545336.png)

Manually trigger build & cancel.

![image-20241201134615939](Readme.assets/image-20241201134615939.png)

"Build with Parameters" in left tab.

![image-20241201134749481](Readme.assets/image-20241201134749481.png)

![image-20241201135132927](Readme.assets/image-20241201135132927.png)

Check demo app helm repo.

![image-20241201135034394](Readme.assets/image-20241201135034394.png)

![image-20241201135226813](Readme.assets/image-20241201135226813.png)

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### Demo#3

> Image updater

Update interval in deployment `argocd-image-updater`.

```bash
kubectl edit deploy argocd-image-updater -n argo-cd
```

```yaml
 37       containers:
 38       - args:
 39         - run
 40         - '--interval'  # ++
 41         - 30s           # ++
 42         env:
 43         - name: APPLICATIONS_API
```

Copy demo values.yaml under to demo app helm repository.

![image-20241201144106454](Readme.assets/image-20241201144106454.png)

Add, Commit & Push.

```bash
git add .
git commit -m "argocd demo3 values.yaml"
git push -u origin main
```

Then apply argocd application.

```bash
kubectl apply -f manifest/demo3-application.yaml
```

Check on argocd dashboard.

![image-20241201151013771](Readme.assets/image-20241201151013771.png)

![image-20241201151027890](Readme.assets/image-20241201151027890.png)

Modify source `foo/templates/index.html`.

```html
<div class="version-info">v0.1.3</div>
```

Build & Push image to harbor.

```bash
cd foo

# login
docker login harbor.devsecops.yukanyan.us.kg -u admin -p admin

# build
docker build -t harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.1.3 .

# push
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.1.3
```

Check on harbor dashboard.



#### demo#4

#### demo#5

#### demo#6
