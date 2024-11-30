# https://docs.k3s.io/installation/private-registry#without-tls
# /etc/rancher/k3s/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "http://harbor.${prefix}.${domain}"
configs:
  "harbor.${prefix}.${domain}":
    auth:
      username: admin # this is the registry username
      password: ${harbor_pwd} # this is the registry password