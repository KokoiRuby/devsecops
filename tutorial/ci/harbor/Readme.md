## [Harbor](https://goharbor.io/docs/2.12.0/install-config/)

Harbor is an open source registry that secures artifacts with policies and role-based access control, ensures images are scanned and free from vulnerabilities, and signs images as trusted.

### [Architecture](https://github.com/goharbor/harbor/wiki/Architecture-Overview-of-Harbor)

#### Fundamental Services

1. **Registry**: The core component for storing and distributing container images.
2. **Core**: Manages image metadata and handles user requests.
3. **Database**: Stores metadata and configurations (usually PostgreSQL).
4. **Job Service**: Manages image replication and other background tasks.
5. **Redis**: Used for caching and session management to improve performance.
6. **Portal**: The web UI for managing Harbor.

### Hands-on

> Default credential: admin/admin

```bash
# export env after terraform apply or terraform output
export HARBOR_URL="https://harbor.${prefix}.${domain}"
```

```bash
# login - admin/admin
docker login $HARBOR_URL -u admin -p admin
```

Login to Harbor Dashboard https://harbor.prefix.domain then [create a project](https://goharbor.io/docs/2.0.0/working-with-projects/create-projects/).

```bash
# tag image
docker tag <image_hash> $HARBOR_URL/<project_name>/<image_name>:<tag>
```

```bash
# push image
docker push $HARBOR_URL/<project_name>/<image_name>:<tag>
```

```bash
# delete local image
docker image rm -f <image_hash>
```

```bash
# pull image
docker pull $HARBOR_URL/<project_name>/<image_name>:<tag>
```

### TODO

- ++ Sign
- ++ Scan
- ++ SBOM

