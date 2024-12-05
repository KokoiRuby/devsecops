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
  memory            = 16
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
  # TODO: wildcard for argocd pr - "*.demo-app"
  # ingress: {{ $.Release.Namespace }}.demo-app.{{ .Values.host.project }}.{{ .Values.host.domain }}
  records              = ["harbor", "jenkins", "sonarqube", "tekton", "argocd", "loki-grafana", "prometheus-grafana", "prometheus", "prometheus-metrics-app", "alert-manager", "otlp-app-a", "otlp-app-b", "otlp-app-c", "demo-app-dev", "demo-app-stage", "demo-app-prod", "jira"]
}

## helm & kubectl ##
provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

provider "kubectl" {
  config_path = local_file.kubeconfig.filename
}