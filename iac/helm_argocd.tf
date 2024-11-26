# # https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#installing-the-chart
# resource "helm_release" "argo-cd" {
#   name             = "argo-cd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = "argo-cd"
#   version          = "v7.7.5"
#   create_namespace = true

#   values = [
#     "${templatefile(
#       "./helm_argocd/http-values.yaml.tpl",
#       {
#         "prefix" : "${var.prefix}"
#         "domain" : "${var.domain}"
#         "argocd_pwd" : "${var.argocd_pwd}"
#       }
#     )}"
#   ]

#   depends_on = [helm_release.ingress-nginx]
# }