# Module for S3 state bucket and DynamoDB lock table
module "s3_backend" {
  source              = "./modules/s3-backend"              # Path to the module
  s3_bucket_name      = "vasyl-p-terraform-states-lesson-5"  # S3 bucket name
  dynamodb_table_name = "terraform-locks"                   # DynamoDB table name
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
  ecr_name           = "lesson5-ecr"            # ECR repository name
  scan_on_push       = true                     # Enable image scan on push
}