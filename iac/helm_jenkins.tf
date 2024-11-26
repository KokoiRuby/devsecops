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

data "kubectl_file_documents" "jenkins-sa" {
  content = file("./helm_jenkins/serviceaccount.yaml")
}

resource "kubectl_manifest" "jenkins-sa" {
  for_each  = data.kubectl_file_documents.jenkins-sa.manifests
  yaml_body = each.value

  depends_on = [helm_release.jenkins]
}

resource "kubectl_manifest" "jenkins-harbor-url" {
  yaml_body = templatefile("./helm_jenkins/secret-harbor-url.yaml.tpl", {
    "prefix" : "${var.prefix}"
    "domain" : "${var.domain}"
  })

  depends_on = [helm_release.jenkins]
}

data "kubectl_file_documents" "jenkins-github-pat" {
  content = templatefile("./helm_jenkins/secret-github-pat.yaml.tpl", {
    "github_username" : "${var.github_username}"
    "github_pat" : "${var.github_pat}"
  })
}

resource "kubectl_manifest" "jenkins-github-pat" {
  for_each  = data.kubectl_file_documents.jenkins-github-pat.manifests
  yaml_body = each.value

  depends_on = [helm_release.jenkins]
}

resource "null_resource" "jenkins-harbor-pullsecret" {
  provisioner "local-exec" {
    command = "kubectl create secret docker-registry harbor-pullsecret --docker-server=harbor.${var.prefix}.${var.domain} --docker-username=admin --docker-password=${var.harbor_pwd} -n jenkins --kubeconfig=config.yaml"
  }

  depends_on = [helm_release.jenkins]
}