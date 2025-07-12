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
