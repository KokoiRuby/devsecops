terraform {
  required_version = "> 0.13.0"

  # comment it if u don't have HCP Terraform
  # change org & workspace if necessary
  # cloud {
  #   organization = "AnSoyo"
  #   workspaces {
  #     name = "devsecops"
  #   }
  # }

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "1.81.140"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}
