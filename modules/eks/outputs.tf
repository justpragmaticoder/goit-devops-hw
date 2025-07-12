output "cluster_id" {
  description = "The unique identifier of the Amazon EKS cluster created by the eks module"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The API endpoint URL for the Amazon EKS cluster, used to configure kubectl and other tools"
  value       = module.eks.cluster_endpoint
}
