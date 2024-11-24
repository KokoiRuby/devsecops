## helm & kubectl ##
provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

provider "kubectl" {
  config_path = local_file.kubeconfig.filename
}

# https://kubernetes.github.io/ingress-nginx/deploy/
resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "v4.11.3"
  create_namespace = true
}

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

resource "kubectl_manifest" "cert-manager-cluster-issuer" {
  yaml_body = templatefile("./helm_cert_manager/cluster-issuer.yaml.tpl", {
    "cloudflare_email" : "${var.cloudflare_email}"
  })

  depends_on = [helm_release.cert-manager]
}


# https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#helm-chart
resource "helm_release" "sealed-secrets" {
  name             = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  chart            = "sealed-secrets"
  namespace        = "kube-system"
  version          = "v2.16.2"
  create_namespace = false
  set {
    name  = "fullnameOverride"
    value = "sealed-secrets-controller"
  }
}

resource "null_resource" "kubeseal" {
  provisioner "local-exec" {
    command = "kubeseal -f helm_sealed_secret/secret-cloudflare-token.yaml -w helm_sealed_secret/sealed-secret-cloudflare-token.yaml --scope cluster-wide --kubeconfig=config.yaml"
  }

  depends_on = [helm_release.sealed-secrets]
}

# cannot use data source since the file will be created after kubeseal
resource "null_resource" "apply_sealed_secret" {
  provisioner "local-exec" {
    command = "kubectl apply -f helm_sealed_secret/sealed-secret-cloudflare-token.yaml --kubeconfig=config.yaml"
  }

  depends_on = [null_resource.kubeseal]
}


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
      "./helm_harbor/https-values.yaml.tpl",
      {
        "prefix" : "${var.prefix}"
        "domain" : "${var.domain}"
      }
    )}"
  ]
}

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
      }
    )}"
  ]
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