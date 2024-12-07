module "k3s" {
  source      = "xunleii/k3s/module"
  k3s_version = "v1.31.2+k3s1"
  
  # cidr = {
  #   pods = var.pod_cidr
  #   services = service_cidr
  # }
  
  generate_ca_certificates = true
  global_flags = [
    "--tls-san ${var.public_ip}",
    "--write-kubeconfig-mode 644",
    "--disable=traefik",
    "--kube-controller-manager-arg bind-address=0.0.0.0",
    "--kube-proxy-arg metrics-bind-address=0.0.0.0",
    "--kube-scheduler-arg bind-address=0.0.0.0",
    "--kube-apiserver-arg feature-gates=InPlacePodVerticalScaling=true"
  ]
  k3s_install_env_vars = {}

  servers = {
    "${var.server_name}" = {
      ip = var.private_ip
      connection = {
        timeout  = "30s"
        type     = "ssh"
        host     = var.public_ip
        user     = var.user
        password = var.password
      }
    }
  }
}
