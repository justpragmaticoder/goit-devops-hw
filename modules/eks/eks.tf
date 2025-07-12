module "eks" {
  # Terraform Registry source for the AWS EKS module
  source  = "terraform-aws-modules/eks/aws"
  # Module version constraint: use any 20.x release
  version = "~> 20.0"

  # The name to assign to your EKS cluster (as seen in the AWS Console and CLI)
  cluster_name    = var.cluster_name
  # Kubernetes version for the control plane and worker nodes
  cluster_version = var.cluster_version

  # List of subnet IDs where EKS control plane ENIs and worker nodes will reside
  subnet_ids = var.subnet_ids
  # The ID of the VPC in which to deploy the EKS cluster
  vpc_id     = var.vpc_id

  # Allow the Kubernetes API server to be publicly accessible
  cluster_endpoint_public_access  = true
  # Also allow the API server to be privately accessible from within the VPC
  cluster_endpoint_private_access = true

  # Configuration for one or more managed node groups
  eks_managed_node_groups = {
    default = {
      # Initial number of worker nodes
      desired_capacity = 2
      # Maximum nodes to scale out
      max_capacity     = 3
      # Minimum nodes to maintain
      min_capacity     = 1

      # EC2 instance types to use for the worker nodes
      instance_types = ["t3.medium"]
    }
  }
}