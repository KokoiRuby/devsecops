controller:
  containerEnv:
    - name: HARBOR_URL
      value: "harbor.${prefix}.${domain}"
  ingress:
    enabled: true
    hostName: jenkins.${prefix}.${domain}
    ingressClassName: nginx
  admin:
    password: ${jenkins_pwd}
  # https://plugins.jenkins.io/
  installPlugins:
    - kubernetes:4296.v20a_7e4d77cf6
    - workflow-aggregator:600.vb_57cdd26fdd7
    - git:5.6.0
    - configuration-as-code:1897.v79281e066ea_7
  additionalPlugins:
    - prometheus:795.v995762102f28
    - kubernetes-credentials-provider:1.262.v2670ef7ea_0c5
    - job-dsl:1.90
    - github:1.40.0
    - github-branch-source:1807.v50351eb_7dd13
    - gitlab-branch-source:715.v4c830b_ca_ef95
    - gitlab-kubernetes-credentials:388.v4c6f01ffdb_c5
    - pipeline-stage-view:2.34
    - sonar:2.17.3
    - pipeline-utility-steps:2.18.0
