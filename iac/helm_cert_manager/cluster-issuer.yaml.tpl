apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: lets-encrypt
spec:
  acme:
    # https://letsencrypt.org/
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${cloudflare_email}
    privateKeySecretRef:
      name: lets-encrypt
    solvers:
      - dns01:
          cloudflare:
            email: ${cloudflare_email}
            apiTokenSecretRef:
              name: cloudflare-api-token
              key: api-token