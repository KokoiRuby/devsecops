# https://goharbor.io/docs/2.0.0/install-config/harbor-ha-helm/
resource "helm_release" "harbor" {
  name             = "harbor"
  repository       = "https://helm.goharbor.io"
  chart            = "harbor"
  namespace        = "harbor"
  version          = "v1.16.0"
  create_namespace = true

  values = [
    "${templatefile(
      "./helm_harbor/http-values.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
        "harbor_pwd" : "${var.harbor_pwd}"
      }
    )}"
  ]

  depends_on = [helm_release.ingress-nginx]
}

resource "null_resource" "upload_k3s_registries" {
  connection {
    type     = "ssh"
    host     = module.cvm.public_ip
    user     = "ubuntu"
    password = var.password
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/rancher/k3s",
    ]
  }

  provisioner "file" {
    content = templatefile("helm_harbor/http-k3s-registries.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
        "harbor_pwd" : "${var.harbor_pwd}"
    })

    destination = "/tmp/registries.yaml"
  }

  provisioner "remote-exec" {
    inline = [ 
        "sudo mv /tmp/registries.yaml /etc/rancher/k3s/registries.yaml",
        "sudo chown root:root /etc/rancher/k3s/registries.yaml",
        "",
     ]
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo systemctl restart k3s"
  #   ]
  # }

  depends_on = [module.cvm]
}