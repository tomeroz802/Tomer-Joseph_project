provider "aws" {
  region = var.networking.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
terraform {
  required_version = ">= 1.0.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.18.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}
