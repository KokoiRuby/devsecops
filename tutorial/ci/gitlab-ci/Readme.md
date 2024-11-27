## [GitLab CI](https://docs.gitlab.com/ee/ci/)

GitLab CI/CD helps ensure that the code deployed to production complies with your established code standards.

[`.gitlab-ci.yml`](https://docs.gitlab.com/ee/ci/yaml/index.html)

- **stage**: Use `stage` to define which [stage](https://docs.gitlab.com/ee/ci/yaml/index.html#stages) a job runs in.

- **image**: Use `image` to specify a Docker image that the **job** runs in.

- **variables**: Use `variables` to define [CI/CD variables](https://docs.gitlab.com/ee/ci/variables/index.html#define-a-cicd-variable-in-the-gitlab-ciyml-file) for jobs.

- **services**: Use `services` to specify any additional Docker images that your **scripts** require to run successfully.

- **before_script**: Use `before_script` to define an array of commands that should run before each job’s `script` commands.

![img](https://docs.gitlab.co.jp/ee/ci/introduction/img/gitlab_workflow_example_11_9.png)

### [Build Docker images](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)

**DinD**: "Docker-in-Docker"

### Hands-on

#### Demo#1

#### Demo#2

#### Demo#3