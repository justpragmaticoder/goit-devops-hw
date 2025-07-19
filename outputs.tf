# ---------------------------------------------------------------------------
# Outputs for backend resources
# ---------------------------------------------------------------------------

output "s3_bucket_name" {
  # Name of the Amazon S3 bucket where Terraform stores the remote state file.
  description = "Name of the S3 bucket that stores the Terraform remote state file"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  # Name of the DynamoDB table that the backend uses to acquire a lock
  # before reading or writing the state file, preventing concurrent runs.
  description = "Name of the DynamoDB table used by Terraform for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "jenkins_release" {
  # Helm release name for the Jenkins deployment in Kubernetes.
  description = "The Helm release name of the Jenkins deployment"
  value       = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  # Kubernetes namespace where Jenkins is deployed.
  description = "The Kubernetes namespace for the Jenkins deployment"
  value       = module.jenkins.jenkins_namespace
}