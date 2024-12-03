## [Trivy](https://trivy.dev/latest/)

A comprehensive and versatile **security scanner** look for security issues, and *targets* where it can find those issues.

### [Installation](https://trivy.dev/v0.57/getting-started/installation/)

### CI

**Jenkins**: exec trivy in `aquasec/trivy` container

**Tekton**: [trivy-scanner](https://hub.tekton.dev/tekton/task/trivy-scanner)

**Dockerfile**: multi-stage build

```dockerfile
# ...
# Run vulnerability scan on build image
FROM build AS vulnscan
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
RUN trivy filesystem --exit-code 1 --no-progress /
# ...
```

### Hands-on

#### Demo#1

> Scan source code

Go to demo app source repo.

```bash
cd foo
```

```bash
# export sbom
trivy fs ./ --format spdx-json --output trivy-spdx.json

# scan sbom
trivy sbom ./trivy-spdx.json

# scan sbom directly
trivy fs ./

# quality gate - exit when cve is found
trivy fs ./ --exit-code 1
```

#### Demo#2

> Scane image

```bash
# export sbom from image & scan
trivy image --format spdx-json --output spdx-image-result.json <repo/image:tag>

# or directly
trivy image <repo/image:tag>
```

#### Demo#3

> Sign image

```bash
# gen key pair
$ cosign generate-key-pair

# sign image where key can be kept in vault, k8s secret or cloud provider managed service
export COSIGN_PASSWORD=...
cosign sign harbor.registry/project/image:tag --key cosign.key -y
```

