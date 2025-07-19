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

# -----------------------------------------------------------------------------
# RDS / Aurora Module Invocation
# -----------------------------------------------------------------------------
# This block instantiates the reusable RDS module, provisioning either a
# two‑node Aurora PostgreSQL cluster or a single‑instance PostgreSQL database
# depending on the `use_aurora` flag. Values marked "Aurora‑only" are ignored
# when standard RDS is selected and vice‑versa.
# -----------------------------------------------------------------------------
module "rds" {
  source = "./modules/rds"                 # Relative path to the RDS module

  # ---------------------------
  # Naming & high‑level toggle
  # ---------------------------
  name           = "myapp-db"              # Prefix for DB resources
  use_aurora     = true                    # true = Aurora cluster, false = single RDS instance
  aurora_instance_count = 2               # 1 writer + 1 reader (minimum 2 for HA)

  # ---------------------------
  # Aurora‑specific settings
  # ---------------------------
  engine_cluster             = "aurora-postgresql"   # Aurora engine
  engine_version_cluster     = "15.3"                # Aurora engine version
  parameter_group_family_aurora = "aurora-postgresql15" # PG family for Aurora

  # ---------------------------
  # Standard RDS‑specific settings (ignored if use_aurora = true)
  # ---------------------------
  engine                     = "postgres"            # Engine for single instance
  engine_version             = "17.2"                # Engine version for single instance
  parameter_group_family_rds = "postgres17"          # PG family for RDS

  # ---------------------------
  # Common settings (apply to both Aurora & RDS)
  # ---------------------------
  instance_class    = "db.t3.medium"      # Instance size
  allocated_storage = 20                  # Storage (only for standard RDS)
  db_name           = "myapp"             # Initial database name
  username          = "postgres"          # Master user
  password          = "admin123AWS23"     # Master password (should be stored in secrets manager)

  # Networking
  subnet_private_ids  = module.vpc.private_subnets # Used when publicly_accessible = false
  subnet_public_ids   = module.vpc.public_subnets  # Used when publicly_accessible = true
  publicly_accessible = true                      # Expose public endpoint
  vpc_id              = module.vpc.vpc_id         # VPC where DB will reside
  multi_az            = true                      # Enable Multi‑AZ for standard RDS

  # Backup & maintenance
  backup_retention_period = 7                     # Keep automated backups for 7 days

  # Custom engine parameters
  parameters = {
    max_connections            = "200"           # Increase connection limit
    log_min_duration_statement = "500"           # Log long‑running queries (ms)
  }

  # Tagging for cost tracking & ownership
  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
