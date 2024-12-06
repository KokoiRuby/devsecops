# ## main.tf ##
# # cvm + k3s
# module "cvm_thanos" {
#   source            = "./module/cvm"
#   secret_id         = var.secret_id
#   secret_key        = var.secret_key
#   vpc_id            = module.vpc.vpc_id
#   subnet_id         = module.vpc.subnet_id
#   sg_id             = module.vpc.sg_id
#   cpu               = 4
#   memory            = 16
#   region            = var.region
#   availability_zone = var.availability-zone
#   password          = var.password
# }

# ## k3s ##
# module "k3s_thanos" {
#   source     = "./module/k3s"
#   public_ip  = module.cvm.public_ip
#   private_ip = module.cvm.private_ip
#   password   = var.password

#   depends_on = [module.cvm_thanos]
# }

# resource "local_file" "kubeconfig_thanos" {
#   content  = module.k3s.kube_config
#   filename = "${path.module}/config_thanos.yaml"

#   depends_on = [module.k3s_thanos]
# }

# # cos
# module "cos" {
#   source     = "./module/cos"
#   secret_id  = var.secret_id
#   secret_key = var.secret_key
#   region     = var.region
# }


# ## variables.tf ##


# ## outputs.tf ##

