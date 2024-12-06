# cos
module "cos" {
  source     = "./module/cos"
  secret_id  = var.secret_id
  secret_key = var.secret_key
  region     = var.region
}

# thanos sidecar secret for cos
# remove this file if necessary
# rm /tmp/rendered_kaniko_docker_credentials.json
resource "local_file" "render_thanos_sidecar_cos_secret_config" {
  filename = "/tmp/render_thanos_sidecar_cos_secret_config.yaml"
  content = templatefile("helm_thanos/1/object-store.yaml.tpl",
    {
      "bucket_name" = module.cos.bucket_name
      "app_id"      = module.cos.app_id
      "region"      = var.region
      "endpoint"    = module.cos.endpoint
      "secret_id"   = var.secret_id
      "secret_key"  = var.secret_key
  })

  depends_on = [module.cos]
}

resource "null_resource" "create_thanos_sidecar_cos_secret" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=config.yaml create secret generic thanos-object-storage --from-file=thanos.yaml=${local_file.render_thanos_sidecar_cos_secret_config.filename} -n monitoring"
  }

  depends_on = [helm_release.prometheus, local_file.render_thanos_sidecar_cos_secret_config]
}

# deploy thanos
# https://github.com/thanos-io/kube-thanos
resource "null_resource" "deploy_thanos" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=config.yaml get ns thanos || kubectl --kubeconfig=config.yaml create ns thanos "
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=config.yaml apply -f helm_thanos/kube-thanos/manifest-out-of-box/ -n thanos"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=config.yaml delete secret thanos-object-storage -n thanos && kubectl --kubeconfig=config.yaml create secret generic thanos-object-storage --from-file=thanos.yaml=${local_file.render_thanos_sidecar_cos_secret_config.filename} -n thanos"
  }

  depends_on = [local_file.render_thanos_sidecar_cos_secret_config]
}