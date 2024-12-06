output "cvm_public_ip" {
  value = module.cvm.public_ip
}

output "cvm_ssh_cmd" {
  value = "ssh ubuntu@${module.cvm.public_ip} (pwd: ${var.password})"
}

output "cvm1_public_ip" {
  value = module.cvm1.public_ip
}

output "cvm1_ssh_cmd" {
  value = "ssh ubuntu@${module.cvm1.public_ip} (pwd: ${var.password})"
}

output "cvm2_public_ip" {
  value = module.cvm2.public_ip
}

output "cvm2_ssh_cmd" {
  value = "ssh ubuntu@${module.cvm2.public_ip} (pwd: ${var.password})"
}

output "export_kubeconfig_cmd" {
  value = "export KUBECONFIG=./config.yaml"
}

output "export_kubeconfig1_cmd" {
  value = "export KUBECONFIG=./config1.yaml"
}

output "export_kubeconfig2_cmd" {
  value = "export KUBECONFIG=./config2.yaml"
}