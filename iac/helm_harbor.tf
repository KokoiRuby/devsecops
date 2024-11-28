# # https://goharbor.io/docs/2.0.0/install-config/harbor-ha-helm/
# resource "helm_release" "harbor" {
#   name             = "harbor"
#   repository       = "https://helm.goharbor.io"
#   chart            = "harbor"
#   namespace        = "harbor"
#   version          = "v1.16.0"
#   create_namespace = true

#   values = [
#     "${templatefile(
#       "./helm_harbor/http-values.yaml.tpl",
#       {
#         "prefix" : "${var.prefix}"
#         "domain" : "${var.domain}"
#         "harbor_pwd" : "${var.harbor_pwd}"
#       }
#     )}"
#   ]

#   depends_on = [helm_release.ingress-nginx]
# }