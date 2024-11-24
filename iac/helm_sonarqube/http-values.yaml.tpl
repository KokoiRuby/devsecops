account:
  adminPassword: "${sonarqube_pwd}"
  currentAdminPassword: "${sonarqube_pwd}"

ingress:
  enabled: true
  hosts:
    - name: "sonarqube.${prefix}.${domain}"
  ingressClassName: nginx