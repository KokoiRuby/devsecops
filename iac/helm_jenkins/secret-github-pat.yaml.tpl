apiVersion: v1
kind: Secret
metadata:
  name: jenkins-github-pat
  namespace: jenkins
  labels:
    "jenkins.io/credentials-type": "usernamePassword"
  annotations:
    "jenkins.io/credentials-description" : "credentials from Kubernetes"
type: Opaque
stringData:
  username: "${github_username}"
  password: "${github_pat}"