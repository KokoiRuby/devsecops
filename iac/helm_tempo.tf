# https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  version          = "v66.2.2"
  create_namespace = true

  values = [
    "${templatefile(
      "./helm_tempo/prometheus-http-values.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
      }
    )}"
  ]

  depends_on = [ helm_release.ingress-nginx ]
}

# https://grafana.com/docs/loki/latest/setup/install/helm/install-microservices/
resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "loki-stack"
  version          = "v6.21.0"
  create_namespace = true

  values = [
    "${file("./helm_loki/loki-filesystem-http-values.yaml")}"
  ]
}

# https://grafana.com/docs/loki/latest/send-data/promtail/installation/
resource "helm_release" "promtail" {
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  namespace        = "loki-stack"
  version          = "v6.16.6"
  create_namespace = true

  values = [
    "${file("./helm_loki/promtail-http-values.yaml")}"
  ]
}

# demo1
# https://grafana.com/docs/tempo/latest/setup/helm-chart/
resource "helm_release" "tempo" {
  name             = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  namespace        = "monitoring"
  version          = "1.14.0"
  create_namespace = true
}