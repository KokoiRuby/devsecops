externalURL: http://harbor.${prefix}.${domain}

expose:
  type: ingress
  tls:
    enabled: false
  ingress:
    hosts:
      core: harbor.${prefix}.${domain}
    className: "nginx"