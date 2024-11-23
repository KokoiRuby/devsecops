output "public_ip" {
  description = "The public ip of instance."
  value       = tencentcloud_instance.ubuntu[0].public_ip
}

output "private_ip" {
  description = "The private ip of instance."
  value       = tencentcloud_instance.ubuntu[0].private_ip
}

output "ssh_password" {
  description = "The SSH password of instance."
  value       = var.password
}
