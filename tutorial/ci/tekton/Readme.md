## [Tekton](https://tekton.dev/docs/)

Tekton is a **cloud-native** solution for building CI/CD pipelines.

It installs and runs as an **extension** on a Kubernetes cluster and comprises a set of Kubernetes **Custom Resources** that define the building blocks you can create and reuse for your pipelines.

### [Concept model](https://tekton.dev/docs/concepts/concept-model/)

A **step** is an operation in a CI/CD workflow, such as build/test/push. Tekton performs each step with a **container** image you provide.

A **task** <u>(reusable)</u> is a collection of **steps** in order in the form of a **pod** where each step becomes a running container.

A **pipeline** is a collection of **tasks** in order. Tekton collects all the tasks, connects them in a **directed acyclic graph (DAG)**.

A **workspace** (PVC) allows allow task(s) within a Tekton pipeline to share ccontext.

![Tasks and Pipelines](https://tekton.dev/docs/concepts/concept-tasks-pipelines.png)

A **pipelineRun** is a specific execution of a **pipeline** given inputs.

A **taskRun** is a specific execution of a **task** given inputs.

![Runs](https://tekton.dev/docs/concepts/concept-runs.png)

### [Triggers](https://tekton.dev/docs/triggers/)

A Tekton component that allows you to detect and extract information from events from a variety of sources and deterministically instantiate and execute [`TaskRuns`](https://github.com/tektoncd/pipeline/blob/master/docs/taskruns.md) and [`PipelineRuns`](https://github.com/tektoncd/pipeline/blob/master/docs/pipelineruns.md) based on that information.

- [`EventListener`](https://tekton.dev/docs/triggers/eventlisteners/) - listens for events (like GitHub webhook) at a specified port on your Kubernetes cluster.

- [`Trigger`](https://tekton.dev/docs/triggers/triggers/) - specifies what happens when the `EventListener` detects an event.

- [`TriggerTemplate`](https://tekton.dev/docs/triggers/triggertemplates/) - specifies a blueprint for the resource that u want to instantiate when `EventListener` detects an event.

- [`TriggerBinding`](https://tekton.dev/docs/triggers/triggerbindings/) - specifies the fields in the event payload from which you want to extract data and the fields in your corresponding `TriggerTemplate` to populate with the extracted values.

  

![TriggerFlow](https://raw.github.com/tektoncd/triggers/release-v0.27.x/docs/images/TriggerFlow.svg)



### [TektonHub](https://hub.tekton.dev/)

### Hands-on

> Note: running TaskRuns and PipelineRuns in the "tekton-pipelines" namespace is [discouraged](https://github.com/tektoncd/pipeline/blob/main/docs/additional-configs.md#running-taskruns-and-pipelineruns-with-restricted-pod-security-standards).

> Dashboard: http://tekton.prefix.domain

```bash
cd tutorial/ci/tekton
export KUBECONFIG=../../../iac/config.yaml
```

#### Demo#1

![tekton-demo1](Readme.assets/tekton-demo1.png)

Create tasks: [git-clone](https://hub.tekton.dev/tekton/task/git-clone) 👉 [sonarqube-scanner](https://hub.tekton.dev/tekton/task/sonarqube-scanner) 👉 [kaniko](https://hub.tekton.dev/tekton/task/kaniko).

```bash
kubectl apply -f "manifest/demo1/task-*"
```

Create a taskrun includes git-clone task only.

```bash
kubectl apply -f manifest/demo1/taskrun.yaml 
```

Check on Dashboard.

![image-20241126204139952](Readme.assets/image-20241126204139952.png)

#### Demo#2

![tekton-demo2](Readme.assets/tekton-demo2.png)

Create sonarqube user token on Sonarqube Dashboard (see more in Jenkins tutorial).

![image-20241127081701355](Readme.assets/image-20241127081701355.png)

Populate token & create user token secret.

```bash
kubectl apply -f manifest/demo2/serviceaccount-sonar-user.yaml
kubectl apply -f manifest/demo2/secret-sonar-user.yaml
```

Create pvc for workspace.

```bash
kubectl apply -f manifest/demo2/pvc-pipeline.yaml
```

Create a pipeline includes git-clone task only.

```bash
kubectl apply -f manifest/demo2/pipeline.yaml
```

Create a pipeline-run to trigger the pipeline.

```bash
kubectl apply -f manifest/demo2/pipeline-run.yaml
```

![image-20241127084905487](Readme.assets/image-20241127084905487.png)

#### Demo#3

![tekton-demo3](Readme.assets/tekton-demo3.png)

Create a pipeline includes git-clone & kaniko build task.

```bash
kubectl apply -f manifest/demo3/pipeline.yaml
```

Create a pipeline-run to trigger the pipeline.

```bash
kubectl apply -f manifest/demo3/pipeline-run.yaml
```

![image-20241127091504441](Readme.assets/image-20241127091504441.png)

![image-20241127091526094](Readme.assets/image-20241127091526094.png)

#### Demo#4

![tekton-demo4](Readme.assets/tekton-demo4.png)

Create a pipeline includes git-clone, sonarqube-scanner, and kaniko build task.

```bash
kubectl apply -f manifest/demo4/pipeline.yaml
```

Create a pipeline-run to trigger the pipeline.

```bash
kubectl apply -f manifest/demo4/pipeline-run.yaml
```

![image-20241127101344439](Readme.assets/image-20241127101344439.png)

#### Demo#5

![tekton-demo4](Readme.assets/tekton-demo5.png)

Create a pipeline that **<u>merge</u>** git-clone, sonarqube-scanner, and kaniko build task.

```bash
kubectl apply -f manifest/demo5/pipeline.yaml
```

Create a pipeline-run to trigger the pipeline.

```bash
kubectl apply -f manifest/demo5/pipeline-run.yaml
```

![image-20241127111005834](Readme.assets/image-20241127111005834.png)

#### Demo#6

![tekton-demo6](Readme.assets/tekton-demo6.png)

Create serviceaccount & RBAC.

```bash
kubectl apply -f manifest/demo6/serviceaccount-trigger.yaml
```

Create EventListener & TriggerTemplate.

```bash
kubectl apply -f manifest/demo6/eventlistener-github.yaml
kubectl apply -f manifest/demo6/triggertemplate-github.yaml
```

![image-20241127151942977](Readme.assets/image-20241127151942977.png)

![image-20241127151952105](Readme.assets/image-20241127151952105.png)

Add tekton webhook in GitHub repository.

![image-20241127142541068](Readme.assets/image-20241127142541068.png)

![image-20241127151118589](Readme.assets/image-20241127151118589.png)

![image-20241127151207380](Readme.assets/image-20241127151207380.png)

Modify source `foo/templates/index.html` & `bar/templates/index.html`.

```bash
<div class="version-info">v0.1.6</div>
```

Add, Commit & Push.

```bash
git add .
git commit -m "tekton demo6"
git push -u origin main
```

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

Check tekton dashboard.

![image-20241127153142540](Readme.assets/image-20241127153142540.png)

![image-20241127153359971](Readme.assets/image-20241127153359971.png)

![image-20241127153431630](Readme.assets/image-20241127153431630.png)

![image-20241127153439742](Readme.assets/image-20241127153439742.png)

![image-20241127153447055](Readme.assets/image-20241127153447055.png)