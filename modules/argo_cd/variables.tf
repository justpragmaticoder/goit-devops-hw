# Variable defining the Helm release name for Argo CD
variable "name" {
  description = "Name of the Helm release for Argo CD"
  type        = string
  default     = "argo_cd"
}

# Variable specifying the Kubernetes namespace where Argo CD will be deployed
variable "namespace" {
  description = "Kubernetes namespace for deploying Argo CD"
  type        = string
  default     = "argocd"
}

# Variable defining the version of the Argo CD Helm chart to use for deployment
variable "chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "5.46.4"
}