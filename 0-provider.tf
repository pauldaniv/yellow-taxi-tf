provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "yellow-taxi-tf-state-east-2"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "yellow-taxi-tf-state"
  }
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }

  required_version = "~> 1.3"
}
