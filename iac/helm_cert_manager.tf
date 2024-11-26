# https://cert-manager.io/docs/installation/helm/
# https://cert-manager.io/docs/usage/ingress/#optional-configuration
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.16.2"
  create_namespace = true
  set {
    name  = "crds.enabled"
    value = true
  }
  set {
    name  = "ingressShim.defaultIssuerName"
    value = "lets-encrypt"
  }
  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }
  set {
    name  = "ingressShim.defaultIssuerGroup"
    value = "cert-manager.io"
  }
}

# cannot use data source since the file will be created after kubeseal
resource "null_resource" "apply_sealed_secret_cloudflare_token" {
  provisioner "local-exec" {
    command = "kubectl apply -f helm_cert_manager/sealed-secret-cloudflare-token.yaml --kubeconfig=config.yaml"
  }

  depends_on = [null_resource.kubeseal_cloudflare_token]
}

resource "kubectl_manifest" "cert-manager-cluster-issuer" {
  yaml_body = templatefile("./helm_cert_manager/cluster-issuer.yaml.tpl", {
    "cloudflare_email" : "${var.cloudflare_email}"
  })

  depends_on = [helm_release.cert-manager, null_resource.apply_sealed_secret_cloudflare_token]
}

