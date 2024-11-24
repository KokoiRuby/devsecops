# note: tekton does not provide helm chart

# https://tekton.dev/docs/installation/
resource "null_resource" "install_tekton_pipeliness" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml"
  }
}

resource "null_resource" "install_tekton_triggers_1" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml"
  }
}

resource "null_resource" "install_tekton_triggers_2" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml"
  }
}

# https://tekton.dev/docs/dashboard/install/
resource "null_resource" "install_tekton_dashboard" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml"
  }
}


resource "kubectl_manifest" "tekton-ingress" {
  yaml_body = templatefile("./helm_tekton/ingress-tekton.yaml.tpl", {
    "prefix" : "${var.prefix}"
    "domain" : "${var.domain}"
  })
}

resource "kubectl_manifest" "tekton-github-pat" {
  yaml_body = templatefile("./helm_tekton/secret-github-pat.yaml.tpl", {
    "github_username" : "${var.github_username}"
    "github_pat" : "${var.github_pat}"
  })
}


data "template_file" "kaniko_docker_credentials" {
  template = file("helm_tekton/kaniko-docker-credential.json.tpl")
  vars = {
    "prefix" : "${var.prefix}"
    "domain" : "${var.domain}"
    "harbor_pwd" : "${harbor_pwd}"
    "harbor_pwd_base64" : "${base64encode("${harbor_pwd}")}"
  }
}

resource "null_resource" "create_kaniko_docker_credentials_secret" {
  provisioner "local-exec" {
    command = "kubectl create secret generic kaniko-docker-credentials --from-file=config.json=${data.template_file.kaniko_docker_credentials.rendered} --dry-run=client -o yaml | kubectl apply -f -"
  }
}
