## [Jira](https://www.atlassian.com/software/jira)

A project management and issue tracking tool developed by Atlassian.

It is widely used by software development for tracking bugs, managing projects, and facilitating agile development methodologies.

### Trunk-based Development vs. GitFlow

**Trunk-based Development** (Quality < Efficiency) 👉 ApplicationSet + PR Generator

:smile:

- At the beginning of the project, team wants to deliver the MVP as soon as possible.

- Rapid iteration: sprinting towards delivery.

- Small team & most members are senior developers: trust and autonomy.

  

![trunk-based](Readme.assets/trunk-based.png)

**Gitflow** (Quality > Efficiency) 👉 ApplicationSet  + List Generator

:smile:

- Open source.
- Large team & Most members are junior developers.
- Stable product & large team, need stric code reviews.

![git-flow](Readme.assets/git-flow.png)

### Hands-on

![workflow](Readme.assets/workflow.png)

![jenkins-prod](Readme.assets/jenkins-prod.png)



#### Demo#1

> Smart commit

Note: you might meet 504 Gateway Time-out. Please check jira-0 pod log & refresh the page later if necessary.

Set up application properties on jira dashboard.

![image-20241203193825376](Readme.assets/image-20241203193825376.png)

Generate trail license. Note: you need a Atlanssian account.

![image-20241203194430865](Readme.assets/image-20241203194430865.png)

Set up admin account. **Note: you need to use the same email as the one in Github that contains demo app source repo.**

![image-20241203194905379](Readme.assets/image-20241203194905379.png)

Good to go.

![image-20241203195132098](Readme.assets/image-20241203195132098.png)

Create a scrum project & specify the key.

![image-20241203195147105](Readme.assets/image-20241203195147105.png)

![image-20241203195235417](Readme.assets/image-20241203195235417.png)

"Manage apps".

![image-20241203195408262](Readme.assets/image-20241203195408262.png)

"Applications" 👉 "DVCS accounts".

![image-20241203195507802](Readme.assets/image-20241203195507802.png)

Create client id & secret in GitHub and add to jira.

![image-20241203195703585](Readme.assets/image-20241203195703585.png)

![image-20241203195749898](Readme.assets/image-20241203195749898.png)

![image-20241203195809955](Readme.assets/image-20241203195809955.png)

![image-20241203200032849](Readme.assets/image-20241203200032849.png)

Authorize.

![image-20241203200134080](Readme.assets/image-20241203200134080.png)

![image-20241203200223183](Readme.assets/image-20241203200223183.png)

![image-20241203200246705](Readme.assets/image-20241203200246705.png)

Create a test issue.

![image-20241203200459961](Readme.assets/image-20241203200459961.png)

Check created issue. Note: the ticket number is what we want to correlate with commit.

![image-20241203200644498](Readme.assets/image-20241203200644498.png)

Create a commit in demo app source repo given ticket number.

```bash
git commit -a -m 'DEVSECOPS-1 #comment test1' --allow-empty
git push -u origin main
```

Check on jira dashboard.

![image-20241203201654730](Readme.assets/image-20241203201654730.png)

Similarly.

```bash
# log time spent on the issue.
git commit -a -m 'DEVSECOPS-1 #time 2h' --allow-empty
git push -u origin main
```

```bash
# transition the issue to the "In Progress" status.
git commit -a -m 'DEVSECOPS-1 #in-progress' --allow-empty
git push -u origin main
```

```bash
# transition the issue to the "Done" status.
git commit -a -m 'DEVSECOPS-1 #done' --allow-empty
```

#### Demo#2

> Jenkins parallel build

Create a multibranch pipeline.

![image-20241203202810561](Readme.assets/image-20241203202810561.png)

![image-20241203202856275](Readme.assets/image-20241203202856275.png)

![image-20241203203359122](Readme.assets/image-20241203203359122.png)

![image-20241203203422537](Readme.assets/image-20241203203422537.png)

Setup sonarqube in jenkins dashboard.

![image-20241204150018158](Readme.assets/image-20241204150018158.png)

Create sonar token. 

![image-20241204143902191](Readme.assets/image-20241204143902191.png)

Populate token & create secret.

```bash
export KUBECONFIG=./config.yaml
kubectl apply -f helm_sonarqube/secret-sonar-token.yaml
```

Copy `Jenkinsfile-demo2` to demo app source repo.

![image-20241203205012002](Readme.assets/image-20241203205012002.png)

Add, Commit & Push

```bash
git add .
git commit -m "jira jenkins demo2"
git push -u origin main
```

Check on jenkins dashboard.

![image-20241203205650685](Readme.assets/image-20241203205650685.png)

Check on harbor dashboard.

![image-20241203205703846](Readme.assets/image-20241203205703846.png)

#### Demo#3

> PR env http://demo-app.ns.project.domain in PR commit

> **Please switch to the [twin](https://github.com/KokoiRuby/devsecops-demo-app-helm-argocd-pr) helm repo in order to proceed with the following demo.**

Copy values.yaml to demo app helm repo.

![image-20241204105405592](Readme.assets/image-20241204105405592.png)

Add, Commit & Push

```bash
git add .
git commit -m "jira argocd demo3"
git push -u origin main
```

Apply application set.

```bash
export KUBECONFIG=../../iac/config.yaml
kubectl apply -f argocd/manifest/applicationset-demo3.yaml
```

Create a dev branch in demo app source repo.

![image-20241204131918079](Readme.assets/image-20241204131918079.png)

![image-20241204131930486](Readme.assets/image-20241204131930486.png)

Modify `foo/templates/index.html` & `foo/templates/index.html`.

```html
<div class="version-info">v0.3.3-pr</div>
```

Add, Commit & Push

```bash
git add .
git commit -m "jira argocd demo3"
git push -u origin main
```

![image-20241204132548857](Readme.assets/image-20241204132548857.png)

Create pull request.

![image-20241204132642360](Readme.assets/image-20241204132642360.png)

Check on argocd dashboard.

![image-20241204133922610](Readme.assets/image-20241204133922610.png)

![image-20241204133933723](Readme.assets/image-20241204133933723.png)

Check pull request in demo app source repo.

![image-20241204150145993](Readme.assets/image-20241204150145993.png)

Verify. Note: you need to add DNS records in cloudflare and wait for a while.

![image-20241204134700946](Readme.assets/image-20241204134700946.png)

![image-20241204135354937](Readme.assets/image-20241204135354937.png)

![image-20241204135409091](Readme.assets/image-20241204135409091.png)

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### Demo#4

> Multi-cluster/env

Copy demo4-env folder to demo app helm repo.

![image-20241204151859575](Readme.assets/image-20241204151859575.png)

Add, Commit & Push

```bash
git add .
git commit -m "jira argocd demo4"
git push -u origin main
```

Setup clusters in argocd dashboard. Note: modify cluster name & add another one.

```bash
# login
argocd login argocd.devsecops.yukanyan.us.kg

# add cluster
argocd cluster add cluster.local --kubeconfig=/path/to/config.yaml
```

Apply application set.

```bash
export KUBECONFIG=../../iac/config.yaml
kubectl apply -f argocd/manifest/applicationset-demo4.yaml
```

Check on argocd dashboard.

**(TODO)**

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### Demo#5

> Jenkins publishes release information in Jira

Copy `Jenkinsfile-demo5` to demo app source repo.

![image-20241204154659683](Readme.assets/image-20241204154659683.png)

Add, Commit & Push

```bash
git add .
git commit -m "jira jenkins demo2"
git push -u origin main
```

Create a pipeline in jenkins dashboard, and copy content of `Jenkinsfile-demo5` into.

![image-20241204155730386](Readme.assets/image-20241204155730386.png)

Build and cancel to resolve parameters. Then refresh the page.

![image-20241204155835174](Readme.assets/image-20241204155835174.png)

Create a release in jira dashboard. 

**(TODO)**

Move backlog issue to release.

**(TODO)**

Populate.

![image-20241204160344277](Readme.assets/image-20241204160344277.png)

Check on jira dashboard.

**(TODO)**

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```
