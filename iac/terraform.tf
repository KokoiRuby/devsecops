terraform {
  required_version = "> 0.13.0"

  # currently it does not support remote backend

  # comment it if u don't have HCP Terraform
  # change org & workspace if necessary
  # cloud {
  #   organization = "AnSoyo"
  #   workspaces {
  #     name = "devsecops"
  #   }
  # }

  required_providers {
    # https://registry.terraform.io/providers/tencentcloudstack/tencentcloud/latest/docs
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "1.81.140"
    }
    # https://registry.terraform.io/providers/hashicorp/helm/latest
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    # https://registry.terraform.io/providers/gavinbunney/kubectl/latest
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
