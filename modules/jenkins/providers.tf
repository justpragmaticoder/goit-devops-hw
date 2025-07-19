# Define required Terraform providers for the Jenkins module
terraform {
  required_providers {

    # Helm provider is used to deploy Jenkins using Helm charts
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"  # Minimum version of the Helm provider
    }
  }
}