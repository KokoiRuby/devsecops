configs:
  secret:
    # -- Bcrypt hashed admin password
    ## Argo expects the password in the secret to be bcrypt hashed. You can create this hash with
    ## `htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'`
    argocdServerAdminPassword: ${argocd_pwd}
  cm:
    timeout.reconciliation: 30s
  params:
    server.insecure: true

server:
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - "argocd.${prefix}.${domain}"
