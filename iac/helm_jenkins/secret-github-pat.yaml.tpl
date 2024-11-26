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
---
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-github-pat-text
  namespace: jenkins
  labels:
    "jenkins.io/credentials-type": "secretText"
  annotations:
    "jenkins.io/credentials-description" : "github pat"
type: Opaque
stringData:
  text: "${github_pat}"