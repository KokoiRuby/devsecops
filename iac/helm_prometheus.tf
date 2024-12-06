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
      "./helm_prometheus/http-values.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
      }
    )}"
  ]

  depends_on = [helm_release.ingress-nginx]
}

# prometheus demo1
# https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter
# resource "helm_release" "prometheus-blackbox-exporter" {
#   name             = "prometheus-blackbox-exporter"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "prometheus-blackbox-exporter"
#   namespace        = "monitoring"
#   version          = "v9.1.0"
#   create_namespace = true
# }

# hpa demo1
# https://artifacthub.io/packages/helm/prometheus-community/prometheus-adapter
# resource "helm_release" "prometheus-adapter" {
#   name             = "prometheus-adapter"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "prometheus-adapter"
#   namespace        = "monitoring"
#   version          = "v4.11.0"
#   create_namespace = true

#   values = [ "${file("./helm_prometheus/adapter-http-values.yaml")}" ]
# }

# keda demo1
# resource "helm_release" "keda" {
#   name             = "keda"
#   repository       = "https://kedacore.github.io/charts"
#   chart            = "keda"
#   namespace        = "keda"
#   version          = "v2.16.0"
#   create_namespace = true
# }