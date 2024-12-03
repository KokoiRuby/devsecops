ingress:
  create: true
  nginx: true
  host: jira.${prefix}.${domain}
  path: "/"
  https: false
