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

[Image Updater](https://argocd-image-updater.readthedocs.io/en/stable/) via [annotations](https://argocd-image-updater.readthedocs.io/en/stable/configuration/images/) - **Registry pull secret is required**. (modify `values.yaml` in app def repo won't trigger sync).

Update strategies:

- [semver](https://argocd-image-updater.readthedocs.io/en/stable/basics/update-strategies/#strategy-semver) - Update to the latest version of an image considering semantic versioning constraints
- [latest/newest-build](https://argocd-image-updater.readthedocs.io/en/stable/basics/update-strategies/#strategy-latest) - Update to the most recently built image found in a registry
- [digest](https://argocd-image-updater.readthedocs.io/en/stable/basics/update-strategies/#strategy-digest) - Update to the latest version of a given version (tag), using the tag's SHA digest
- [name/alphabetical](https://argocd-image-updater.readthedocs.io/en/stable/basics/update-strategies/#strategy-name) - Sorts tags alphabetically and update to the one with the highest cardinality

### Multi-env

- Multi-branch: dev/test/stage

  :thumbsup: Strong isolation and facilitates differentiated control over environments

  :thumbsdown: Branch management can be challenging, making it difficult to share configurations

- **Multi-dir: .dev/.test/.stage** →　auto-generate [ApplicationSet](https://argo-cd.readthedocs.io/en/latest/user-guide/application-set/) = template → **Dir/[PR](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/)-as-a-Env**

  :thumbsup: Easy to maintaine & allows for sharing cross-environment conf

### Multi-cluster

- one ArgoCD vs. many clusters

  :thumbsup: Central view, easy to maintain

  :thumbsdown: Single point of failure, all cluster cred kept in one place (management cluster)

- one ArgoCD per cluster

  :thumbsup: Isolation btw

  :thumbsdown: Duplicate instances

### Hands-on

> Demo app src  [repository](https://github.com/KokoiRuby/devsecops-demo-app)
>
> Demo app helm [repository](https://github.com/KokoiRuby/devsecops-demo-app-helm)

Configure argocd webhook in demo app helm repo.

![image-20241201201301276](Readme.assets/image-20241201201301276.png)

![image-20241201201315119](Readme.assets/image-20241201201315119.png)

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
docker tag <image_hash> harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.2.0
docker tag <image_hash> harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:v0.2.0
```

```bash
# push
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.1.0
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:v0.1.0
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.2.0
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:v0.2.0
```

Check on harbor dashboard.

![image-20241201202939175](Readme.assets/image-20241201202939175.png)

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

(Optional) Update interval in deployment `argocd-image-updater`.

```bash
kubectl edit deploy argocd-image-updater -n argocd
```

```yaml
 37       containers:
 38       - args:
 39         - run
 40         - '--interval'  # ++
 41         - 20s           # ++
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

![image-20241201192541387](Readme.assets/image-20241201192541387.png)

Check demo app helm repository.

![image-20241201195717365](Readme.assets/image-20241201195717365.png)

Check on argocd dashboard.

![image-20241201195537183](Readme.assets/image-20241201195537183.png)

Verify URL.

- http://demo-app-dev.devsecops.yukanyan.us.kg/foo

In the end, rollback & prepare for the next demo.

```bash
kubectl delete -f manifest/demo3-application.yaml
```

```bash
# rollback
git pull -r
git reset --hard <recorded_commit_hash>
git push --force
```

#### demo#4

> Multi-env

![multi-env](Readme.assets/multi-env.png)

Copy demo values.yaml under to demo app helm repository.

![image-20241201202020516](Readme.assets/image-20241201202020516.png)

Add, Commit & Push.

```bash
git add .
git commit -m "argocd demo4 values.yaml"
git push -u origin main
```

Then apply argocd application.

```bash
kubectl apply -f manifest/demo4-application-dev.yaml
kubectl apply -f manifest/demo4-application-stage.yaml
```

Check on argocd dashboard.
![image-20241201202954073](Readme.assets/image-20241201202954073.png)

Verify URL.

- http://demo-app-dev.devsecops.yukanyan.us.kg/foo
- http://demo-app-dev.devsecops.yukanyan.us.kg/bar
- http://demo-app-stage.devsecops.yukanyan.us.kg/foo
- http://demo-app-stage.devsecops.yukanyan.us.kg/bar

Modify demo app source repo. Re-build & re-push the image to harbor.

```bash
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:v0.1.4
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:v0.1.4
```

![image-20241201203826950](Readme.assets/image-20241201203826950.png)

![image-20241201203847394](Readme.assets/image-20241201203847394.png)

#### demo#5

#### demo#6
