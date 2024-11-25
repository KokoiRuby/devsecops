apiVersion: v1
kind: Secret
metadata:
  name: tekton-github-pat
  namespace: default
  annotations:
    tekton.dev/git-0: https://github.com
type: kubernetes.io/basic-auth
stringData:
  username: "${github_username}"
  password: "${github_pat}"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-build-bot
  namespace: default
secrets:
  - name: basic-user-pass
