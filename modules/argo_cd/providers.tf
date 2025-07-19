# Configure required providers and their versions for the Terraform project
terraform {
  required_providers {

    # AWS provider to interact with Amazon Web Services resources
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"  # Minimum required version of AWS provider
    }

    # Helm provider to manage Helm charts on Kubernetes clusters
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"  # Minimum required version of Helm provider
    }

    # Kubernetes provider to manage Kubernetes resources directly
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"  # Minimum required version of Kubernetes provider
    }
  }
}