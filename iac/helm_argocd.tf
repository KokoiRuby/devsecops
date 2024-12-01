# https://github.com/argoproj/argo-helm/tree/main/charts/argocd#installing-the-chart
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "v7.7.5"
  create_namespace = true

  values = [
    "${templatefile(
      "./helm_argocd/http-values.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
        "argocd_pwd" : "${var.argocd_pwd}"
      }
    )}"
  ]

  depends_on = [helm_release.ingress-nginx]
}

# https://argocd-image-updater.readthedocs.io/en/stable/install/installation/
resource "null_resource" "install_argocd_image_updater" {
  provisioner "local-exec" {
    command = "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml --kubeconfig=config.yaml"
  }
  
  depends_on = [ helm_release.argocd ]
}

# http only
resource "null_resource" "update_argocd_image_updater_config" {
  provisioner "local-exec" {
    command = "kubectl create configmap argocd-image-updater-config -n argocd --from-literal=registries.conf='registries:\n- name: Harbor for DevSecOps Demo App\n  api_url: http://harbor.${var.prefix}.${var.domain}\n  insecure: yes' --kubeconfig=config.yaml"
  }
  
  depends_on = [ null_resource.install_argocd_image_updater ]
}


resource "kubectl_manifest" "argocd-github-pat" {
  yaml_body = templatefile("./helm_argocd/secret-github-pat.yaml.tpl", {
    "github_username" : "${var.github_username}"
    "github_pat" : "${var.github_pat}"
  })

  depends_on = [helm_release.argocd]
}

# remove this file if necessary
# rm /tmp/rendered_argocd_docker_credentials.json
resource "local_file" "render_argocd_image_updater_docker_credentials_json" {
  filename = "/tmp/rendered_argocd_image_updater_docker_credentials.json"
  content = templatefile("helm_argocd/argocd-image-updater-docker-credential.json.tpl",
    {
      "prefix" : "${var.prefix}"
      "domain" : "${var.domain}"
      "harbor_pwd" : "${var.harbor_pwd}"
      "harbor_pwd_base64" : "${base64encode("admin:${var.harbor_pwd}")}"
  })
}

resource "null_resource" "create_argocd_image_updater_docker_credentials_secret" {
  provisioner "local-exec" {
    command = "kubectl -n argocd create secret generic argocd-image-updater-docker-credentials --from-file=.dockerconfigjson=${local_file.render_argocd_image_updater_docker_credentials_json.filename} --dry-run=client -o yaml | kubectl --kubeconfig=config.yaml apply -f -"
  }

  depends_on = [helm_release.argocd]
}