apiVersion: v1
kind: Secret
metadata:
  name: harbor-url
  namespace: jenkins
  labels:
    "jenkins.io/credentials-type": "secretText"
  annotations:
    "jenkins.io/credentials-description": "harbor-url"
type: Opaque
stringData:
  text: harbor.${prefix}.${domain}