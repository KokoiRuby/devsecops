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

- **Multi-dir: .dev/.test/.stage** →　[ApplicationSet](https://argo-cd.readthedocs.io/en/latest/user-guide/application-set/) + [Generators](https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators/) = template → **Dir/[PR](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Pull-Request/)-as-a-Env**

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
# login
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
kubectl delete ns devsecops-demo-app-dev
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

In the end, rollback & prepare for the next demo.

```bash
kubectl delete -f manifest/demo4-application-dev.yaml
kubectl delete -f manifest/demo4-application-stage.yaml
kubectl delete ns devsecops-demo-app-dev
kubectl delete ns devsecops-demo-app-stage
```

```bash
# rollback
git pull -r
git reset --hard <recorded_commit_hash>
git push --force
```

#### demo#5

> ApplicationSet - [Git Generator](https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Git/)

Modify `foo/templates/index.html` & `bar/templates/index.html` in demo app source repo then build & push images.

```html
<div class="version-info">dev-main-v0.1.5</div>
<div class="version-info">stage-main-v0.2.5</div>
```

```bash
docker build -t harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:dev-main-v0.1.5 .
docker build -t harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:dev-main-v0.1.5 .
docker build -t harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:stage-main-v0.2.5 .
docker build -t harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:stage-main-v0.2.5 .

docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:dev-main-v0.1.5
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:dev-main-v0.1.5
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo:stage-main-v0.2.5
docker push harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar:stage-main-v0.2.5
```

Check on harboar dashboard.

![image-20241201210607180](Readme.assets/image-20241201210607180.png)

![image-20241201210615175](Readme.assets/image-20241201210615175.png)

Create env dir in demo app helm repo directory.

```bash
mkdir -p env/{dev,stage}
```

Copy values.yaml to each env dir.

![image-20241201205201059](Readme.assets/image-20241201205201059.png)

Add, Commit & Push.

```bash
git add .
git commit -m "argocd demo5 values.yaml"
git push -u origin main
```

Then apply argocd application set.

```bash
kubectl apply -f manifest/demo5-applicationset.yaml
```

Check on argocd dashboard.

![image-20241201212336247](Readme.assets/image-20241201212336247.png)

Verify URL.

- http://demo-app-dev.devsecops.yukanyan.us.kg/foo
- http://demo-app-dev.devsecops.yukanyan.us.kg/bar
- http://demo-app-stage.devsecops.yukanyan.us.kg/foo
- http://demo-app-stage.devsecops.yukanyan.us.kg/bar

In the end, rollback & prepare for the next demo.

```bash
kubectl delete -f manifest/demo5-applicationset.yaml
kubectl delete ns devsecops-demo-app-auto-generator-dev
kubectl delete ns devsecops-demo-app-auto-generator-dev
```

```bash
# rollback
git pull -r
git reset --hard <recorded_commit_hash>
git push --force
```

#### demo#6

> ApplicationSet - [PR Generator](https://argo-cd.readthedocs.io/en/latest/operator-manual/applicationset/Generators-Pull-Request/)

Setup GitHub Action in demo app source repo first.

```bash
mkdir -p .github/workflows
```

```yaml
name: argocd pr applicationset

on:
  push:

jobs:
  docker:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - image: harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/foo
            path: foo
          - image: harbor.devsecops.yukanyan.us.kg/devsecops-demo-app/bar
            path: bar
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Insecure Docker Repository
        run: |
          cat /etc/docker/daemon.json
          sudo truncate -s-2 /etc/docker/daemon.json
          echo ", \"insecure-registries\": [\"harbor.devsecops.yukanyan.us.kg\"]}" | sudo tee -a /etc/docker/daemon.json
          sudo systemctl restart docker

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          registry: harbor.devsecops.yukanyan.us.kg
          username: ${{ secrets.HARBOR_USERNAME }}
          password: ${{ secrets.HARBOR_PASSWORD }}

      - name: Extract metadata for Docker
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ matrix.image }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: ./${{ matrix.path }}
          file: ${{ matrix.path }}/Dockerfile
          push: true
          tags: ${{ matrix.image }}:${{ github.sha }}
```

Add, Commit & Push.

```bash
git add .
git commit -m "argocd demo6 github action workflow"
git push -u origin main
```

Copy values.yaml to demo app helm repo.

![image-20241202091817587](Readme.assets/image-20241202091817587.png)

Add, Commit & Push.

```bash
git add .
git commit -m "argocd demo6 values.yaml"
git push -u origin main
```

Apply argocd application set.

```bash
kubectl apply -f manifest/demo6-applicationset.yaml
```

Create a branch & a PR in demo app source repo.

![image-20241202085105878](Readme.assets/image-20241202085105878.png)

![image-20241202090143285](Readme.assets/image-20241202090143285.png)

![image-20241202090608170](Readme.assets/image-20241202090608170.png)

Check on argocd dashboard.

![image-20241202092611368](Readme.assets/image-20241202092611368.png)

Close PR.

![image-20241202092736228](Readme.assets/image-20241202092736228.png)

Check on argocd dashboard.

![image-20241202092755106](Readme.assets/image-20241202092755106.png)

In the end, rollback & prepare for the next demo.

```bash
kubectl delete -f manifest/demo6-applicationset.yaml
```

```bash
# rollback
git pull -r
git reset --hard <recorded_commit_hash>
git push --force
```

#### Demo#7

> Multi-cluster

Add cluster via argocd cli.

```bash
# login
argocd login argocd.devsecops.yukanyan.us.kg
```

```bash
# add cluster
argocd cluster add dev --kubeconfig=config.yaml
argocd cluster add stage --kubeconfig=config.yaml
```

Apply argocd application set.

```bash
kubectl apply -f manifest/demo7-applicationset.yaml
```

