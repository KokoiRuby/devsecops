# https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
# resource "helm_release" "prometheus" {
#   name             = "kube-prometheus-stack"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "kube-prometheus-stack"
#   namespace        = "monitoring"
#   version          = "v66.2.2"
#   create_namespace = true

#   values = [
#     "${templatefile(
#       "./helm_prometheus/http-values.yaml.tpl",
#       {
#         "prefix" : "${var.prefix}"
#         "domain" : "${var.domain}"
#       }
#     )}"
#   ]

#   depends_on = [ helm_release.ingress-nginx ]
# }

# demo1
# https://artifacthub.io/packages/helm/prometheus-community/prometheus-blackbox-exporter
# resource "helm_release" "prometheus-demo1" {
#   name             = "prometheus-blackbox-exporter"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "prometheus-blackbox-exporter"
#   namespace        = "monitoring"
#   version          = "v9.1.0"
#   create_namespace = true
# }
