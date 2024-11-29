grafana:
  adminPassword: "admin"
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
    hosts:
    - prometheus-grafana.${prefix}.${domain}
  sidecar:
    dashboards:
      provider:
        # enable grafana dashboard edit
        allowUiUpdates: true
  service:
    type: NodePort
    nodePort: 30080

prometheus:
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
    hosts: 
    - prometheus.${prefix}.${domain}
  prometheusSpec:
    enableFeatures:
    - exemplar-storage
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false
    externalLabels:
      cluster: k3s-hongkong-2
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 20Gi
  service:
    type: NodePort
    nodePort: 30090

alertmanager:
  enabled: true
  service:
    type: NodePort
    nodePort: 30092
  alertmanagerSpec:
    alertmanagerConfigSelector:
      matchLabels:
        app: alertmanager
  config:
    global:
      resolve_timeout: 1m # 5m
    route:
      group_by: ["job"]
      group_wait: 10s
      group_interval: 1m # 5m
      repeat_interval: 1m # 12h
      receiver: "prometheusalert"
      routes:
        - receiver: "null"
          continue: true
          matchers:
            - alertname =~ "InfoInhibitor|Watchdog"
    receivers:
      - name: "null"
      - name: "prometheusalert"
        # TODO
        webhook_configs:
          - url: "http://prometheus-alert-center.monitoring:8080/prometheusalert?type=fs&tpl=prometheus-fs&fsurl=https://open.feishu.cn/open-apis/bot/v2/hook/735cbc74-ad11-47b4-9a92-b18636dc4b64"
    templates:
      - "/etc/alertmanager/config/*.tmpl"
