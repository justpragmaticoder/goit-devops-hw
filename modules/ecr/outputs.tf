output "ecr_repo_url" {
  # Fully qualified URI of the Amazon ECR repository created by this module
  # (e.g. 123456789012.dkr.ecr.us-west-2.amazonaws.com/homework-05-ecr).
  # Use this URL when tagging and pushing Docker images or when referencing
  # the repository in ECS/EKS task definitions and deployment pipelines.
  description = "Fully qualified URI of the Amazon ECR repository created by this module"
  value       = aws_ecr_repository.ecr_repository.repository_url
}