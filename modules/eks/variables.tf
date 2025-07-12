# The unique name to assign to your Amazon EKS cluster.
# This appears in the AWS Console, CLI, and is used to identify the cluster.
variable "cluster_name" {
  description = "Unique name for the EKS cluster (visible in AWS Console and CLI)"
  type        = string
}

# The Kubernetes version to use for both the control plane and worker nodes.
# Must match a supported EKS version (e.g., \"1.29\").
variable "cluster_version" {
  description = "Kubernetes version for the EKS control plane and nodes"
  type        = string
  default     = "1.29"
}

# A list of subnet IDs where the EKS control plane ENIs and worker nodes will be launched.
# These subnets must belong to the same VPC.
variable "subnet_ids" {
  description = "List of subnet IDs for placing EKS control plane ENIs and worker nodes"
  type        = list(string)
}

# The ID of the VPC in which to create the EKS cluster.
# All subnets provided above must reside within this VPC.
variable "vpc_id" {
  description = "VPC ID where the EKS cluster and its resources will be deployed"
  type        = string
}