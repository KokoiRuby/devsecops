module "vpc" {
  source            = "./module/vpc"
  secret_id         = var.secret_id
  secret_key        = var.secret_key
  region            = var.region
  availability_zone = var.availability-zone
}

# karmada
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

# pod & service cidr must be different in order to make submarine work
module "k3s" {
  source      = "./module/k3s"
  server_name = "karmada"

  public_ip  = module.cvm.public_ip
  private_ip = module.cvm.private_ip
  password   = var.password

  # pod_cidr     = var.pod_cidr
  # service_cidr = var.service_cidr

  depends_on = [module.cvm]
}

resource "local_file" "kubeconfig" {
  content  = module.k3s.kube_config
  filename = "${path.module}/config.yaml"
}

# cluster1
module "cvm1" {
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

# pod & service cidr must be different in order to make submarine work
module "k3s1" {
  source      = "./module/k3s"
  server_name = "cluster-1"

  public_ip  = module.cvm1.public_ip
  private_ip = module.cvm1.private_ip
  password   = var.password

  # pod_cidr     = var.pod_cidr
  # service_cidr = var.service_cidr

  depends_on = [module.cvm1]
}

resource "local_file" "kubeconfig1" {
  content  = module.k3s1.kube_config
  filename = "${path.module}/config1.yaml"
}

# cluster2
module "cvm2" {
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

# pod & service cidr must be different in order to make submarine work
module "k3s2" {
  source      = "./module/k3s"
  server_name = "cluster-2"

  public_ip  = module.cvm2.public_ip
  private_ip = module.cvm2.private_ip
  password   = var.password

  # pod_cidr     = var.pod_cidr
  # service_cidr = var.service_cidr

  depends_on = [module.cvm2]
}

resource "local_file" "kubeconfig2" {
  content  = module.k3s2.kube_config
  filename = "${path.module}/config2.yaml"
}