# https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3
resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = "jenkins"
  version          = "v5.7.14"
  create_namespace = true

  values = [
    "${templatefile(
      "./helm_jenkins/http-values.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
        "jenkins_pwd" : "${var.jenkins_pwd}"
      }
    )}"
  ]

  depends_on = [helm_release.ingress-nginx]
}

resource "kubectl_manifest" "jenkins-sa" {
  yaml_body = file("./helm_jenkins/serviceaccount.yaml")

  depends_on = [helm_release.jenkins]
}

resource "kubectl_manifest" "jenkins-harbor-url" {
  yaml_body = templatefile("./helm_jenkins/secret-harbor-url.yaml.tpl", {
    "prefix" : "${var.prefix}"
    "domain" : "${var.domain}"
  })

  depends_on = [helm_release.jenkins]
}

resource "kubectl_manifest" "jenkins-github-pat" {
  yaml_body = templatefile("./helm_jenkins/secret-github-pat.yaml.tpl", {
    "github_username" : "${var.github_username}"
    "github_pat" : "${var.github_pat}"
  })

  depends_on = [helm_release.jenkins]
}