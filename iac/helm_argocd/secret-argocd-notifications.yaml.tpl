apiVersion: v1
kind: Secret
metadata:
  name: argocd-notifications-secret
  namespace: argocd
  annotations:
    app.kubernetes.io/part-of: argocd
stringData:
  github_pat: "${github_pat}"
type: Opaque
