# -----------------------------------------------------------------------------
# RDS & Aurora Outputs
# -----------------------------------------------------------------------------
# Exposes connection details and metadata for either a standard RDS instance or
# an Aurora cluster, depending on which option is enabled in the module.
# -----------------------------------------------------------------------------

# -------------------------------
# Standard RDS (single-instance)
# -------------------------------
output "db_instance_endpoint" {
  description = "Endpoint of the standard RDS instance (if enabled)"
  value       = try(aws_db_instance.standard[0].endpoint, null)
}

output "db_instance_port" {
  description = "Port of the standard RDS instance (if enabled)"
  value       = try(aws_db_instance.standard[0].port, null)
}

output "db_instance_arn" {
  description = "ARN of the standard RDS instance (if enabled)"
  value       = try(aws_db_instance.standard[0].arn, null)
}

# -------------------------------
# Amazon Aurora (cluster)
# -------------------------------
output "aurora_cluster_endpoint" {
  description = "Writer endpoint of the Aurora cluster (if enabled)"
  value       = try(aws_rds_cluster.aurora[0].endpoint, null)
}

output "aurora_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster (if enabled)"
  value       = try(aws_rds_cluster.aurora[0].reader_endpoint, null)
}

output "aurora_cluster_arn" {
  description = "ARN of the Aurora cluster (if enabled)"
  value       = try(aws_rds_cluster.aurora[0].arn, null)
}

# -------------------------------
# Common credentials & DB name
# -------------------------------
output "db_name" {
  description = "Name of the database created in RDS/Aurora"
  value       = var.db_name
}

output "username" {
  description = "Database master username"
  value       = var.username
}

output "password" {
  description = "Database master password (sensitive)"
  value       = var.password
  sensitive   = true
}