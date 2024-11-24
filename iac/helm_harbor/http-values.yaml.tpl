externalURL: http://harbor.${prefix}.${domain}

harborAdminPassword: ${harbor_pwd}

expose:
  type: ingress
  tls:
    enabled: false
  ingress:
    hosts:
      core: harbor.${prefix}.${domain}
    className: "nginx"