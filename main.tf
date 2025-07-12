# Module for S3 state bucket and DynamoDB lock table
module "s3_backend" {
  source              = "./modules/s3-backend"                       # Path to the module
  s3_bucket_name      = "vasyl-p-lesson-7"                           # S3 bucket name
  dynamodb_table_name = "terraform-locks"                            # DynamoDB table name
}

# Module for the VPC
module "vpc" {
  source             = "./modules/vpc"                                 # Path to the VPC module
  vpc_cidr_block     = "10.0.0.0/16"                                   # CIDR block for the VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]   # Public subnets
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]   # Private subnets
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]      # Availability zones
  vpc_name           = "vpc"                                           # VPC name
}

# Module for ECR
module "ecr" {
  source             = "./modules/ecr"          # Path to the ECR module
  ecr_name           = "lesson-7-ecr"           # ECR repository name
  scan_on_push       = true                     # Enable image scan on push
}

# Module for EKS
module "eks" {
  source         = "./modules/eks"              # Path to the local module that provisions an Amazon EKS cluster
  cluster_name   = "lesson-7-eks"               # The name to assign to your EKS cluster (as seen in the AWS Console and CLI)
  cluster_version = "1.29"                      # The Kubernetes version for the control plane and nodes
  subnet_ids     = module.vpc.public_subnets    # List of subnet IDs where EKS worker nodes will be launched
  vpc_id         = module.vpc.vpc_id            # The ID of the VPC in which to create the EKS cluster
}