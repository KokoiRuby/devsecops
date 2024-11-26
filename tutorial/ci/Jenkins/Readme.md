## [Jenkins](https://www.jenkins.io/doc/)

Jenkins is a self-contained, open source automation server which can be used to automate all sorts of tasks related to building, testing, and delivering or deploying software.

### [`Jenkinsfile`](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/)

A `Jenkinsfile` is a text file that contains the definition of a Jenkins Pipeline and is checked into source control.

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
```

### [Kaniko](https://github.com/GoogleContainerTools/kaniko)

A tool to build container images from a Dockerfile, inside a container or Kubernetes cluster.

It **doesn't depend on a Docker daemon** and executes each command within a Dockerfile completely in userspace.

### [Plugins](https://plugins.jenkins.io/)

### Hands-on

> Demo App GitHub [repository](https://github.com/KokoiRuby/devsecops-demo-app)

#### Credentials

```bash
# harbor pullsecret which will be mounted to Kaniko container /kaniko/.docker
kubectl get secret harbor-pullsecret -n jenkins -o yaml
```

```bash
# git checkout
# https://jenkinsci.github.io/kubernetes-credentials-provider-plugin/
kubectl get secret jenkins-github-pat -n default -o yaml
kubectl get secret jenkins-github-pat-text -n default -o yaml
```

```bash
# harbor url
# https://jenkinsci.github.io/kubernetes-credentials-provider-plugin/
kubectl get secret harbor-url -n jenkins -o yaml
```

#### Monorepo#1

![mono-repo-1](Readme.assets/mono-repo-1.png)

Create `Jenkinsfile` under each service directory.

```bash
.
├── README.md
├── bar
│   ├── Dockerfile
│   ├── Jenkinsfile    # ++
│   ├── go.mod
│   ├── go.sum
│   ├── main.go
│   └── templates
│       └── index.html
└── foo
    ├── Dockerfile
    ├── Jenkinsfile    # ++
    ├── go.mod
    ├── go.sum
    ├── main.go
    └── templates
        └── index.html
```

```groovy
pipeline {
    agent none
    stages {
        stage('Build with Kaniko') {
            agent {
                kubernetes {
                    defaultContainer 'kaniko'
                    yaml """
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.2-debug
    imagePullPolicy: Always
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: harbor-pullsecret
          items:
            - key: .dockerconfigjson
              path: config.json
"""
                }
            }

            environment {
                HARBOR_URL     = credentials('harbor-url')
                IMAGE_PUSH_DESTINATION="${HARBOR_URL}/devsecops/demo-app-foo"
                GIT_COMMIT="${checkout (scm).GIT_COMMIT}"
                IMAGE_TAG = "${BRANCH_NAME}-${GIT_COMMIT}"
                BUILD_IMAGE="${IMAGE_PUSH_DESTINATION}:${IMAGE_TAG}"
                BUILD_IMAGE_LATEST="${IMAGE_PUSH_DESTINATION}:latest"
            }

            steps {
                container(name: 'kaniko', shell: '/busybox/sh') {
                    withEnv(['PATH+EXTRA=/busybox']) {
                        sh '''#!/busybox/sh
                            cd foo
                            /kaniko/executor --context `pwd` --destination $IMAGE_PUSH_DESTINATION --insecure
                        '''
                    }
                }
            }
        }
    }
}
```

```bash
# record current commit hash which will be used later for git rest
git show --oneline -s
```

```bash
# add & commit
git add .
git commit -m "monorepo-1"
git push -u origin main
```

Login to Jenkins Dashboard https://jenkins.prefix.domain then create Multibranch Pipeline for each service.

![image-20241126110132001](Readme.assets/image-20241126110132001.png)

Select "GitHub" as branch source.

![image-20241126110435128](Readme.assets/image-20241126110435128.png)

Select "GitHub Credentials" & fill in "Repository HTTPS URL".

![image-20241126112126727](Readme.assets/image-20241126112126727.png)

Update "Script Path".

![image-20241126112454833](Readme.assets/image-20241126112454833.png)

Enable periodical scan given 1 min interval then head to "Save".

![image-20241126112316754](Readme.assets/image-20241126112316754.png)

Verify

![image-20241126112853395](Readme.assets/image-20241126112853395.png)

Built & pushed successfully.

![image-20241126113113522](Readme.assets/image-20241126113113522.png)

![image-20241126113133386](Readme.assets/image-20241126113133386.png)

![image-20241126113235210](Readme.assets/image-20241126113235210.png)

Instead, we could switch to "Push" mode, which means the pipeline will be triggered whenever commit on GitHub Repo. Disable scan first.

![image-20241126133328466](Readme.assets/image-20241126133328466.png)

"Manage Jenkins" 👉 "System"

![image-20241126133622848](Readme.assets/image-20241126133622848.png)

"Add GitHub Server"

![image-20241126133828018](Readme.assets/image-20241126133828018.png)

![image-20241126134907680](Readme.assets/image-20241126134907680.png)

Get Hook URL

![image-20241126134936858](Readme.assets/image-20241126134936858.png)

Back to GitHub repository 👉 "Setting" 👉 "Webhooks". Note: MFA is required.

![image-20241126135101782](Readme.assets/image-20241126135101782.png)

![image-20241126135352504](Readme.assets/image-20241126135352504.png)

"Ping" successfully.

![image-20241126135441324](Readme.assets/image-20241126135441324.png)

Trigger an empty commit.

```bash
git commit --allow-empty -m "test jenkins webhook"
git push -u origin main
```

Built & pushed successfully.

![image-20241126140125040](Readme.assets/image-20241126140125040.png)

![image-20241126140145567](Readme.assets/image-20241126140145567.png)

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### Monorepo#2

![mono-repo-2](Readme.assets/mono-repo-2.png)

Create `Jenkinsfile` under each service directory.

```bash
.
├── README.md
├── bar
│   ├── Dockerfile
│   ├── Jenkinsfile    # ++
│   ├── go.mod
│   ├── go.sum
│   ├── main.go
│   └── templates
│       └── index.html
└── foo
    ├── Dockerfile
    ├── Jenkinsfile    # ++
    ├── go.mod
    ├── go.sum
    ├── main.go
    └── templates
        └── index.html
```

 ```groovy
 pipeline {
     agent none
     stages {
         stage('Build with Kaniko') {
             when {
                 changeset "**/bar/**"
             }
             agent {
                 kubernetes {
                     defaultContainer 'kaniko'
                     //workspaceVolume persistentVolumeClaimWorkspaceVolume(claimName: "jenkins-workspace-pvc", readOnly: false)
                     yaml """
 kind: Pod
 spec:
   containers:
   - name: kaniko
     image: gcr.io/kaniko-project/executor:v1.23.2-debug
     imagePullPolicy: Always
     command:
     - sleep
     args:
     - 99d
     volumeMounts:
       - name: jenkins-docker-cfg
         mountPath: /kaniko/.docker
   volumes:
   - name: jenkins-docker-cfg
     projected:
       sources:
       - secret:
           name: harbor-pullsecret
           items:
             - key: .dockerconfigjson
               path: config.json
 """
                 }
             }
 
             environment {
                 HARBOR_URL     = credentials('harbor-url')
                 IMAGE_PUSH_DESTINATION="${HARBOR_URL}/devsecops/demo-app-bar"
                 GIT_COMMIT="${checkout (scm).GIT_COMMIT}"
                 IMAGE_TAG = "${BRANCH_NAME}-${GIT_COMMIT}"
                 BUILD_IMAGE="${IMAGE_PUSH_DESTINATION}:${IMAGE_TAG}"
                 BUILD_IMAGE_LATEST="${IMAGE_PUSH_DESTINATION}:latest"
             }
 
             steps {
                 container(name: 'kaniko', shell: '/busybox/sh') {
                     withEnv(['PATH+EXTRA=/busybox']) {
                         sh '''#!/busybox/sh
                             cd bar
                             /kaniko/executor --context `pwd` --destination $IMAGE_PUSH_DESTINATION --insecure
                         '''
                     }
                 }
             }
         }
     }
 }
 ```

Add, Commit & Push

```bash
git add .
git commit -m "jenkins demo-2 on-demand build"
git push -u origin main
```

Modify source `foo/templates/index.html`.

```html
<div class="version-info">v0.1.2</div>
```

```bash
git add .
git commit -m "jenkins demo-2 on-demand build foo v0.1.2"
git push -u origin main
```

Built & pushed successfully.

![image-20241126143128939](Readme.assets/image-20241126143128939.png)

![image-20241126143201027](Readme.assets/image-20241126143201027.png)

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### Monorepo#3

![mono-repo-3](Readme.assets/mono-repo-3.png)

Create `Jenkinsfile` under root directory.

```bash
.
├── Jenkinsfile # ++
├── README.md
├── bar
│   ├── Dockerfile
│   ├── go.mod
│   ├── go.sum
│   ├── main.go
│   └── templates
│       └── index.html
└── foo
    ├── Dockerfile
    ├── go.mod
    ├── go.sum
    ├── main.go
    └── templates
       └── index.html
```

```groovy
pipeline {
    agent none
    stages {
        stage('Build with Kaniko for Foo') {
            when {
                changeset "**/foo/**"
            }
            agent {
                kubernetes {
                    defaultContainer 'kaniko'
                    yaml """
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.2-debug
    imagePullPolicy: Always
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: harbor-pullsecret
          items:
            - key: .dockerconfigjson
              path: config.json
"""
                }
            }

            environment {
                HARBOR_URL = credentials('harbor-url')
                IMAGE_PUSH_DESTINATION = "${HARBOR_URL}/devsecops/demo-app-foo"
                GIT_COMMIT = "${checkout(scm).GIT_COMMIT}"
                IMAGE_TAG = "${BRANCH_NAME}-${GIT_COMMIT}"
                BUILD_IMAGE = "${IMAGE_PUSH_DESTINATION}:${IMAGE_TAG}"
                BUILD_IMAGE_LATEST = "${IMAGE_PUSH_DESTINATION}:latest"
            }

            steps {
                container(name: 'kaniko', shell: '/busybox/sh') {
                    withEnv(['PATH+EXTRA=/busybox']) {
                        sh '''#!/busybox/sh
                            cd foo
                            /kaniko/executor --context `pwd` --destination $IMAGE_PUSH_DESTINATION --insecure
                        '''
                    }
                }
            }
        }

        stage('Build with Kaniko for Bar') {
            when {
                changeset "**/bar/**"
            }
            agent {
                kubernetes {
                    defaultContainer 'kaniko'
                    yaml """
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.23.2-debug
    imagePullPolicy: Always
    command:
    - sleep
    args:
    - 99d
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: harbor-pullsecret
          items:
            - key: .dockerconfigjson
              path: config.json
"""
                }
            }

            environment {
                HARBOR_URL = credentials('harbor-url')
                IMAGE_PUSH_DESTINATION = "${HARBOR_URL}/devsecops/demo-app-bar"
                GIT_COMMIT = "${checkout(scm).GIT_COMMIT}"
                IMAGE_TAG = "${BRANCH_NAME}-${GIT_COMMIT}"
                BUILD_IMAGE = "${IMAGE_PUSH_DESTINATION}:${IMAGE_TAG}"
                BUILD_IMAGE_LATEST = "${IMAGE_PUSH_DESTINATION}:latest"
            }

            steps {
                container(name: 'kaniko', shell: '/busybox/sh') {
                    withEnv(['PATH+EXTRA=/busybox']) {
                        sh '''#!/busybox/sh
                            cd bar
                            /kaniko/executor --context `pwd` --destination $IMAGE_PUSH_DESTINATION --insecure
                        '''
                    }
                }
            }
        }
    }
}

```

Create an umbralla multibranch pipeline.

![image-20241126144116806](Readme.assets/image-20241126144116806.png)

![image-20241126144221356](Readme.assets/image-20241126144221356.png)

![image-20241126144231850](Readme.assets/image-20241126144231850.png)

Add, Commit & Push

```bash
git add .
git commit -m "jenkins demo-3"
git push -u origin main
```

Modify source `foo/templates/index.html` & `bar/templates/index.html`.

```html
<div class="version-info">v0.1.3</div>
```

Add, Commit & Push again

```bash
git add .
git commit -m "jenkins demo-3 on-demand build v0.1.3"
git push -u origin main
```

Built & pushed successfully.

![image-20241126145248344](Readme.assets/image-20241126145248344.png)

![image-20241126145311570](Readme.assets/image-20241126145311570.png)

![image-20241126145337612](Readme.assets/image-20241126145337612.png)

![image-20241126145350603](Readme.assets/image-20241126145350603.png)

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### Monorepo#4

![mono-repo-4](Readme.assets/mono-repo-4.png)

```bash
.
├── Jenkinsfile-auto # ++
├── README.md
├── bar
│   ├── Dockerfile
│   ├── Jenkinsfile    # ++
│   ├── go.mod
│   ├── go.sum
│   ├── main.go
│   └── templates
│       └── index.html
├── foo
│   ├── Dockerfile
│   ├── Jenkinsfile    # ++
│   ├── go.mod
│   ├── go.sum
│   ├── main.go
│   └── templates
│       └── index.html
└── pipelineCreator.groovy # ++
```

```groovy
pipeline {
    agent any
    stages{
        stage('Create MultiBranchPipelineJob'){
            steps{
                script{
                    // scan Jenkinsfile from all directories
                    def files = findFiles(glob: '**/Jenkinsfile')
                    def fileCount = files.size()
                    echo "Found ${fileCount} Jenkinsfile(s)"
                    for (int i = 0; i < files.size(); i++) {
                        echo files[i].name
                        def filePath = files[i].path
                        def pathWithoutFile = filePath.replace('/Jenkinsfile', '')
                        def jobName = "auto-gen-" + ( pathWithoutFile =~ /([^\/]+)\/?$/)[0][0]
                        echo filePath
                        echo jobName
                        if(Jenkins.instance.getItemMap()[jobName] == null){
                            echo "Job ${jobName} does not exist, creating..."
                            // create MultiBranchPipelineJob for each directory which contains Jenkinsfile
                            createJob(filePath, jobName)
                        }else{
                            echo "Job ${jobName} already exists."
                        }
                    }
                }
            }
        }

    }
}

def createJob(filePath, jobName){
        jobDsl  targets: '*.groovy',
        removedJobAction: 'IGNORE',
        removedViewAction: 'IGNORE',
        lookupStrategy: 'JENKINS_ROOT',
        additionalParameters: [jenkinsfile: filePath, Name: jobName]
}
```

```groovy
// get all DSL config 
// http://jenkins.prefix.domaion/plugin/job-dsl/api-viewer/index.html
multibranchPipelineJob("${Name}") {
    branchSources {
        branchSource {
            source {
                github {
                    id('github')
                    repoOwner("KokoiRuby")
                    configuredByUrl(false)
                    repository("devsecops-demo-app")
                    repositoryUrl("https://github.com/KokoiRuby/devsecops-demo-app.git")
                    credentialsId('jenkins-github-pat')

                    traits {
                        gitHubBranchDiscovery {
                            strategyId(1)
                        }
                        gitHubPullRequestDiscovery {
                            strategyId(2)
                        }
                    }
                }
            }
        }
        factory {
            workflowBranchProjectFactory {
                scriptPath("${jenkinsfile}")
            }
        }
    }
}
```

Add, Commit & Push

```bash
git add .
git commit -m "jenkins demo-4 auto-gen"
git push -u origin main
```

Create an umbralla Multibranch Pipeline to create children Pipeline.

![image-20241126151715826](Readme.assets/image-20241126151715826.png)

![image-20241126151856761](Readme.assets/image-20241126151856761.png)

![image-20241126151913203](Readme.assets/image-20241126151913203.png)

Need to approve the scripts to run

![image-20241126152742926](Readme.assets/image-20241126152742926.png)

![image-20241126152810456](Readme.assets/image-20241126152810456.png)

![image-20241126152836150](Readme.assets/image-20241126152836150.png)

![image-20241126153137889](Readme.assets/image-20241126153137889.png)

![image-20241126153213836](Readme.assets/image-20241126153213836.png)

![image-20241126153352464](Readme.assets/image-20241126153352464.png)

![image-20241126153409387](Readme.assets/image-20241126153409387.png)

Build now.

![image-20241126155221529](Readme.assets/image-20241126155221529.png)



![image-20241126155133040](Readme.assets/image-20241126155133040.png)

Modify source `foo/templates/index.html` & `bar/templates/index.html`.

```html
<div class="version-info">v0.1.4</div>
```

Add, Commit & Push.

```bash
git add .
git commit -m "jenkins demo-4 auto-gen on-demand build v0.1.4"
git push -u origin main
```

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

#### [SonarQube](https://docs.sonarsource.com/sonarqube/latest/)

It helps developers manage code quality and security continuously by providing detailed insights into codebases.

![SQ instance components](https://assets-eu-01.kc-usercontent.com/de54acbd-b859-01c0-a8dc-f4339e0550f4/0fd3b035-aee8-4039-8a76-f77e93a2b11d/SQ-instance-components.png?w=924&h=451&auto=format&fit=crop)

Create a local project for each service.

![image-20241126183232185](Readme.assets/image-20241126183232185.png)

![image-20241126183320277](Readme.assets/image-20241126183320277.png)

![image-20241126183335091](Readme.assets/image-20241126183335091.png)



Create user token.

![image-20241126183707884](Readme.assets/image-20241126183707884.png)

![image-20241126183802716](Readme.assets/image-20241126183802716.png)

Populate token & create user token secret.

```bash
export KUBECONFIG=./config.yaml
kubectl apply -f helm_sonarqube/secret-sonar-token.yaml
```

Back to Jenkins Dashboard.

![image-20241126184043929](Readme.assets/image-20241126184043929.png)

**Note: no `/` in Server URL.**

![image-20241126184421784](Readme.assets/image-20241126184421784.png)

Update `Jenkinsfile` under each service directory. Pay attention to projectKey in `SONAR_SCANNER_OPTS`.

```groovy
stage('Scan Code with Sonarqube') {
    when {
        changeset "**/bar/**"
    }
    agent {
        kubernetes {
            defaultContainer 'sonar-scanner'
            yaml """
kind: Pod
spec:
  containers:
  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli:11.1
    imagePullPolicy: Always
    command:
    - sleep
    args:
    - 99d
"""
        }
    }

    environment {
        HARBOR_URL = credentials('harbor-url')
        SONAR_TOKEN = credentials('sonarqube-token')
        SONAR_SCANNER_OPTS = "-Dsonar.projectKey=devsecops-demo-app-bar -Dsonar.token=${SONAR_TOKEN}"
        SONAR_HOST_URL = "http://sonar${HARBOR_URL.replaceAll('harbor', '')}."
    }

    steps {
        container(name: 'sonar-scanner', shell: '/bin/sh') {
            withSonarQubeEnv('SonarQube') {
                sh '''#!/bin/sh
                    cd bar
                    sonar-scanner
                '''
            }
            timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
            }
        }
    }
}

```

Modify source `foo/templates/index.html` & `bar/templates/index.html`.

```bash
<div class="version-info">v0.1.5</div>
```

Add, Commit & Push.

```bash
git add .
git commit -m "jenkins sonarqube build v0.1.5"
git push -u origin main
```

Check scan result.

![image-20241126191346381](Readme.assets/image-20241126191346381.png)

In the end, rollback & prepare for the next demo.

```bash
# rollback
git reset --hard <recorded_commit_hash>
git push --force
```

### [HA](https://community.jenkins.io/t/jenkins-high-availablity/9060)