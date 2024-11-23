externalURL: https://harbor.${prefix}.${domain}

expose:
  type: ingress
  tls:
    enabled: true
    certSource: auto
    commonName: ""
  ingress:
    hosts:
      core: harbor.${prefix}.${domain}
    className: "nginx"
    # annotations:
      # cert-manager
      # kubernetes.io/tls-acme: "true"
      # certmanager.k8s.io/issuer: letsencrypt