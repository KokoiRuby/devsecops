# # https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#helm-chart
# resource "helm_release" "sealed-secrets" {
#   name             = "sealed-secrets"
#   repository       = "https://bitnami-labs.github.io/sealed-secrets"
#   chart            = "sealed-secrets"
#   namespace        = "kube-system"
#   version          = "v2.16.2"
#   create_namespace = false
#   set {
#     name  = "fullnameOverride"
#     value = "sealed-secrets-controller"
#   }
# }

# resource "null_resource" "kubeseal_cloudflare_token" {
#   provisioner "local-exec" {
#     command = "kubeseal -f helm_sealed_secret/secret-cloudflare-token.yaml -w helm_cert_manager/sealed-secret-cloudflare-token.yaml --scope cluster-wide --kubeconfig=config.yaml"
#   }

#   depends_on = [helm_release.sealed-secrets]
# }