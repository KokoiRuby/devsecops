output "cvm_public_ip" {
  value = module.cvm.public_ip
}

output "cmv_ssh_cmd" {
  value = "ssh ubuntu@${module.cvm.public_ip} (pwd: ${var.password})"
}

output "export_kubeconfig_cmd" {
  value = "export KUBECONFIG=./config.yaml"
}

## URL

output "harbor_http" {
  value = "http://harbor.${var.prefix}.${var.domain}"
}

# output "harbor_https" {
#   value = "https://harbor.${var.prefix}.${var.domain}"
# }

output "jenkins_http" {
  value = "http://jenkins.${var.prefix}.${var.domain}"
}

# output "jenkins_https" {
#   value = "https://jenkins.${var.prefix}.${var.domain}"
# }

output "sonarqube_http" {
  value = "http://sonarqube.${var.prefix}.${var.domain}"
}

# output "sonarqube_https" {
#   value = "https://sonarqube.${var.prefix}.${var.domain}"
# }

output "tekton_http" {
  value = "http://tekton.${var.prefix}.${var.domain}"
}

# output "tekton_https" {
#   value = "https://tekton.${var.prefix}.${var.domain}"
# }

output "argocd_http" {
  value = "http://argocd.${var.prefix}.${var.domain}"
}

# output "argocd_https" {
#   value = "https://argocd.${var.prefix}.${var.domain}"
# }

output "loki_grafana_http" {
  value = "http://loki-grafana.${var.prefix}.${var.domain}"
}

# output "loki_grafana_https" {
#   value = "https://loki-grafana.${var.prefix}.${var.domain}"
# }

output "prometheus_grafana_http" {
  value = "http://prometheus-grafana.${var.prefix}.${var.domain}"
}

# output "prometheus_grafana_https" {
#   value = "https://prometheus-grafana.${var.prefix}.${var.domain}"
# }

output "prometheus_http" {
  value = "http://prometheus.${var.prefix}.${var.domain}"
}

# output "prometheus_https" {
#   value = "https://prometheus.${var.prefix}.${var.domain}"
# }

output "prometheus_metrics_app_http" {
  value = "http://prometheus-metrics-app.${var.prefix}.${var.domain}"
}

# output "prometheus_metrics_app_https" {
#   value = "https://otlp-app-a.${var.prefix}.${var.domain}"
# }

output "otlp_app_a_http" {
  value = "http://otlp-app-a.${var.prefix}.${var.domain}"
}

# output "otlp_app_a_https" {
#   value = "https://otlp-app-a.${var.prefix}.${var.domain}"
# }

output "otlp_app_b_http" {
  value = "http://otlp-app-b.${var.prefix}.${var.domain}"
}

# output "otlp_app_b_https" {
#   value = "https://otlp-app-b.${var.prefix}.${var.domain}"
# }

output "otlp_app_c_http" {
  value = "http://otlp-app-c.${var.prefix}.${var.domain}"
}

# output "otlp_app_c_https" {
#   value = "https://otlp-app-c.${var.prefix}.${var.domain}"
# }

output "demo_app_dev_http" {
  value = "http://demo-app-dev.${var.prefix}.${var.domain}/foo http://demo-app-dev.${var.prefix}.${var.domain}/bar"
}

# output "demo_app_dev_https" {
#   value = "https://demo-app-dev.${var.prefix}.${var.domain}/foo https://demo-app-dev.${var.prefix}.${var.domain}/bar"
# }

output "demo_app_stage_http" {
  value = "http://demo-app-stage.${var.prefix}.${var.domain}/foo http://demo-app-stage.${var.prefix}.${var.domain}/bar"
}

# output "demo_app_stage_https" {
#   value = "https://demo-app-stage.${var.prefix}.${var.domain}/foo https://demo-app-stage.${var.prefix}.${var.domain}/bar"
# }

output "demo_app_prod_http" {
  value = "http://demo-app-prod.${var.prefix}.${var.domain}/foo http://demo-app-prod.${var.prefix}.${var.domain}/bar"
}

# output "demo_app_prod_https" {
#   value = "https://demo-app-prod.${var.prefix}.${var.domain}/foo https://demo-app-prod.${var.prefix}.${var.domain}/bar"
# }
