apiVersion: v1
kind: Secret
metadata:
  name: jenkins-github-pat
  labels:
    "jenkins.io/credentials-type": "usernamePassword"
  annotations:
    "jenkins.io/credentials-description" : "github pat"
type: Opaque
stringData:
  username: "${github_username}"
  password: "${github_pat}"
---
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-github-pat-text
  labels:
    "jenkins.io/credentials-type": "secretText"
  annotations:
    "jenkins.io/credentials-description": "github pat in text"
type: Opaque
stringData:
  text: "${github_pat}"