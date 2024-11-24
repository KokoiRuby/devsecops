## tencent cloud ##
module "vpc" {
  source            = "./module/vpc"
  secret_id         = var.secret_id
  secret_key        = var.secret_key
  region            = var.region
  availability_zone = var.availability-zone
}

module "cvm" {
  source            = "./module/cvm"
  secret_id         = var.secret_id
  secret_key        = var.secret_key
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.subnet_id
  sg_id             = module.vpc.sg_id
  cpu               = 4
  memory            = 8
  region            = var.region
  availability_zone = var.availability-zone
  password          = var.password
}

## k3s ##
module "k3s" {
  source     = "./module/k3s"
  public_ip  = module.cvm.public_ip
  private_ip = module.cvm.private_ip
  password   = var.password

  depends_on = [module.cvm]
}

resource "local_file" "kubeconfig" {
  content  = module.k3s.kube_config
  filename = "${path.module}/config.yaml"

  depends_on = [module.k3s]
}

## cloudflare ##
# record[].prefix.domain
module "cloudflare" {
  source               = "./module/cloudflare"
  cloudflare_api_token = var.cloudflare_api_token
  domain               = var.domain
  prefix               = var.prefix
  ip                   = module.cvm.public_ip
  records              = ["harbor"]
}

## helm ##
provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
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