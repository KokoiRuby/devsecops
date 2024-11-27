# # https://docs.sonarsource.com/sonarqube/9.9/setup-and-upgrade/deploy-on-kubernetes/deploy-sonarqube-on-kubernetes/
# resource "helm_release" "sonarqube" {
#   name             = "sonarqube"
#   repository       = "https://SonarSource.github.io/helm-chart-sonarqube"
#   chart            = "sonarqube"
#   namespace        = "sonarqube"
#   version          = "v10.7.0+3598"
#   create_namespace = true

#   # avoid context deadline exceeded, default is 300
#   # sonarqube needs to take a bit of time to download
#   timeout = 600

#   values = [
#     "${templatefile(
#       "./helm_sonarqube/http-values.yaml.tpl",
#       {
#         "prefix" : "${var.prefix}"
#         "domain" : "${var.domain}"
#         "sonarqube_pwd" : "${var.sonarqube_pwd}"
#       }
#     )}"
#   ]

#   depends_on = [helm_release.ingress-nginx]
# }