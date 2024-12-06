provider "tencentcloud" {
  secret_id  = var.secret_id
  secret_key = var.secret_key
  region     = var.region
}

resource "tencentcloud_cos_bucket" "cos" {
  bucket = "${var.name}-${data.tencentcloud_user_info.cos.app_id}"
  acl    = "private"
}

data "tencentcloud_user_info" "cos" {}
