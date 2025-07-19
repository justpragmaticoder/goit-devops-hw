# Path to the kubeconfig file used to authenticate with the Kubernetes cluster
variable "kubeconfig" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = ""
}

# Name of the Kubernetes cluster (used for naming IAM roles and resources)
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}