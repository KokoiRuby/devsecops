output "endpoint" {
  value = tencentcloud_cos_bucket.cos.cos_bucket_url
}

output "bucket_name" {
  value = var.name
}

output "app_id" {
  value = data.tencentcloud_user_info.cos.app_id
}
