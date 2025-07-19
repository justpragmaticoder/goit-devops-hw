terraform {
  # Define required Terraform providers and their minimum versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

# Configure AWS provider with the us-west-2 region
provider "aws" {
  region = "us-west-2"
}

# Kubernetes provider configuration using EKS module output
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

# Helm provider configuration for managing Helm charts on Kubernetes cluster
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

# Module for S3 bucket and DynamoDB table for Terraform state management
module "s3_backend" {
  source              = "./modules/s3-backend"                       # Path to the module
  s3_bucket_name      = "vasyl-p-lesson-7"                           # S3 bucket name for storing Terraform state
  dynamodb_table_name = "terraform-locks"                            # DynamoDB table name for state locking
}

# Module for Virtual Private Cloud (VPC) setup
module "vpc" {
  source             = "./modules/vpc"                                 # Path to the VPC module
  vpc_cidr_block     = "10.0.0.0/16"                                   # CIDR block for the entire VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]   # CIDR blocks for public subnets
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]   # CIDR blocks for private subnets
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]      # AWS availability zones for subnets
  vpc_name           = "vpc"                                           # Name assigned to the VPC
}

# Module for Elastic Container Registry (ECR) to store Docker images
module "ecr" {
  source       = "./modules/ecr"          # Path to the ECR module
  ecr_name     = "lesson-7-ecr"           # Name of the ECR repository
  scan_on_push = true                      # Enable vulnerability scanning for images on push
}

# Module for Elastic Kubernetes Service (EKS) to manage Kubernetes clusters
module "eks" {
  source          = "./modules/eks"               # Path to the module provisioning an Amazon EKS cluster
  cluster_name    = "lesson-7-eks"                # Name of the EKS cluster
  cluster_version = "1.29"                        # Kubernetes version used for the cluster
  subnet_ids      = module.vpc.public_subnets      # Subnets for deploying EKS worker nodes
  vpc_id          = module.vpc.vpc_id              # ID of the VPC hosting the EKS cluster
}

# Module to deploy Jenkins on the Kubernetes cluster via Helm
module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.cluster_id

  providers = {
    helm = helm
  }
}

# Module to deploy ArgoCD, a GitOps tool, on Kubernetes
module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"                # Kubernetes namespace for ArgoCD deployment
  chart_version = "5.46.4"                # Helm chart version for ArgoCD
}