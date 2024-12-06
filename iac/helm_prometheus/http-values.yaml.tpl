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
  # service:
  #   type: NodePort
  #   nodePort: 30080

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
    # discover *monitor in all namespaces
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false
    # extra labels
    externalLabels:
      cluster: k3s-hongkong-2
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 20Gi
    # enable thanos sidecaar
    thanos:
      objectStorageConfig:
        existingSecret:
          name: thanos-object-storage
          key: thanos.yaml
  # service:
  #   type: NodePort
  #   nodePort: 30090
  # thanos
  thanosService:
    enabled: true
  thanosServiceMonitor:
    enabled: true
  # Service for external access to sidecar
  # Enabling this creates a service to expose thanos-sidecar outside the cluster.
  thanosServiceExternal:
    enabled: true
  # Ingress exposes thanos sidecar outside the cluster
  # thanosIngress:
  #   enabled: true
  #   annotations:
  #     nginx.ingress.kubernetes.io/ssl-redirect: "false"
  #   ingressClassName: nginx
  #   hosts:
  #   - prometheus-thanos.${prefix}.${domain}
  #   paths: 
  #   - /
  #   pathType: Prefix


alertmanager:
  enabled: true
  ingress:
    enabled: true
    hosts:
    - alert-manager.${prefix}.${domain}
  # service:
  #   type: NodePort
  #   nodePort: 30092
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
      group_interval: 1m  # 5m
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
        # TODO: slack - https://hooks.slack.com/services/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
        webhook_configs:
          - url: "http://prometheus-alert-center.monitoring:8080/prometheusalert?type=fs&tpl=prometheus-fs&fsurl=https://open.feishu.cn/open-apis/bot/v2/hook/735cbc74-ad11-47b4-9a92-b18636dc4b64"
    templates:
      - "/etc/alertmanager/config/*.tmpl"
