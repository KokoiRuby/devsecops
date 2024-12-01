apiVersion: v1
kind: Secret
metadata:
  name: argocd-github-pat
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: "https://github.com/KokoiRuby/devsecops-demo-app-helm.git"
  username: "${github_username}"
  password: "${github_pat}"