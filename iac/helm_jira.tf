# https://atlassian.github.io/data-center-helm-charts/userguide/INSTALLATION/
resource "helm_release" "jira" {
  name             = "jira"
  repository       = "https://atlassian.github.io/data-center-helm-charts"
  chart            = "jira"
  namespace        = "jira"
  version          = "v1.22.0"
  create_namespace = true

  values = [
    "${templatefile(
      "./helm_jira/http-values.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
      }
    )}"
  ]

  depends_on = [helm_release.ingress-nginx]
}