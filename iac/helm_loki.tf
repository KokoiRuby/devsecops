# # https://grafana.com/docs/loki/latest/setup/install/helm/install-microservices/
# resource "helm_release" "loki" {
#   name             = "loki"
#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "loki"
#   namespace        = "loki-stack"
#   version          = "v6.21.0"
#   create_namespace = true

#   values = [
#     "${file("./helm_loki/loki-filesystem-http-values.yaml")}"
#   ]
# }

# # https://grafana.com/docs/loki/latest/send-data/promtail/installation/
# resource "helm_release" "promtail" {
#   name             = "promtail"
#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "promtail"
#   namespace        = "loki-stack"
#   version          = "v6.16.6"
#   create_namespace = true

#   values = [
#     "${file("./helm_loki/promtail-http-values.yaml")}"
#   ]
# }

# # https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/
# resource "helm_release" "grafana" {
#   name             = "grafana"
#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "grafana"
#   namespace        = "loki-stack"
#   version          = "v8.6.3"
#   create_namespace = true
# }

# data "kubectl_file_documents" "grafana-ingress" {
#   content = templatefile("./helm_loki/ingress-grafana.yaml.tpl", {
#     "prefix" : "${var.prefix}"
#     "domain" : "${var.domain}"
#   })
# }

# resource "kubectl_manifest" "grafana-ingress" {
#   for_each  = data.kubectl_file_documents.grafana-ingress.manifests
#   yaml_body = each.value

#   depends_on = [ helm_release.grafana, helm_release.ingress-nginx ]
# }