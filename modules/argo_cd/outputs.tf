# Output the fully qualified domain name (FQDN) of the Argo CD server service within the Kubernetes cluster
output "argo_cd_server_service" {
  description = "Argo CD server service"
  value       = "argo-cd.${var.namespace}.svc.cluster.local"
}

# Instructions to retrieve the initial admin password for Argo CD from Kubernetes secrets
output "admin_password" {
  description = "Initial admin password for accessing Argo CD. Execute the provided kubectl command to retrieve the password."
  value       = "Run: kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
}