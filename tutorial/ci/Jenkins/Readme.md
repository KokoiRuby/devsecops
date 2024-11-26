## [Jenkins](https://www.jenkins.io/doc/)

Jenkins is a self-contained, open source automation server which can be used to automate all sorts of tasks related to building, testing, and delivering or deploying software.

#### [`Jenkinsfile`](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/)

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

#### [Kaniko](https://github.com/GoogleContainerTools/kaniko)

A tool to build container images from a Dockerfile, inside a container or Kubernetes cluster.

It **doesn't depend on a Docker daemon** and executes each command within a Dockerfile completely in userspace.

### Build

![mono-repo-2](Readme.assets/mono-repo-2.png)

![mono-repo-3](Readme.assets/mono-repo-3.png)

![mono-repo-4](Readme.assets/mono-repo-4.png)

### Hands-on

> 

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
```

```bash
# harbor url
# https://jenkinsci.github.io/kubernetes-credentials-provider-plugin/
kubectl get secret harbor-url -n jenkins -o yaml
```

#### Monorepo#1

![mono-repo-1](Readme.assets/mono-repo-1.png)

Create a file named `Jenkinsfile` under each service directory.

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

Select GitHub Credentials & fill in Repository HTTPS URL.

![image-20241126112126727](Readme.assets/image-20241126112126727.png)

Update Script Path.

![image-20241126112454833](Readme.assets/image-20241126112454833.png)

Enable periodical scan given 1 min interval then head to "Save".

![image-20241126112316754](Readme.assets/image-20241126112316754.png)

Verify

![image-20241126112853395](Readme.assets/image-20241126112853395.png)

![image-20241126113113522](Readme.assets/image-20241126113113522.png)

![image-20241126113133386](Readme.assets/image-20241126113133386.png)

![image-20241126113235210](Readme.assets/image-20241126113235210.png)

```bash
# rollback

```



### Monorepo#2







#### Practice

- New item → **Multi-branch pipeline**
  - Branch Sources → "GitHub"
    - Credentials: GitHub personal access token (pat) in kubernetes secret
    - Repository HTTPS URL
    - Build Configuration
      - Script Path - `svc-*/Jenkinsfile`
    - `"Pull"` (from repository) → enable "Periodically if otherwise run" given an interval
- `"Push"` (repositry to Jenkins) - **Plugin(s) is(are) required**
  - Manage Jenkins → "System" → GitHub Server
    - Name
    - API URL
    - Credentials: GitHub personal access token (pat) in kubernetes secret
  - Back to GitHub repository → "Settings" → "Webhooks"
    - Payload URL
    - Content type: application/json
- On-demand build
  - [`when {}`](https://www.jenkins.io/doc/book/pipeline/syntax/#when) + changeset
  - Merge steps in `./svc-*/Jenkinsfile` into `./Jenkinsfile` = One pipeline
  - **Best practice**: auto-generate pipeline whenever a new svc dir is added - **Need script approval** 
    - Manage Jenkins → "In-process" Script Approval

#### [Plugins](https://plugins.jenkins.io/)

#### HA