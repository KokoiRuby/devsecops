output "cvm_public_ip" {
  value = module.cvm.public_ip
}

output "cmv_ssh_cmd" {
  value = "sshpass -p ${var.password} ubuntu@${module.cvm.public_ip}"
}

output "export_kubeconfig_cmd" {
  value = "export KUBECONFIG=./config.yaml"
}