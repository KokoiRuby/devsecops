variable "secret_id" {
  default = ""
}

variable "secret_key" {
  default = ""
}

module "cos" {
  source     = "../../module/cos"
  secret_id  = var.secret_id
  secret_key = var.secret_key
  name       = "velero-cos"
}

output "bucket_name" {
  value = "${module.cos.bucket_name}-${module.cos.app_id}"
}

output "endpoint" {
  value = "https://${module.cos.endpoint}"
}