# -----------------------------------------------------------------------------
# Input Variables — RDS / Aurora Module
# -----------------------------------------------------------------------------
# These variables control whether a standard RDS instance or an Aurora cluster
# is deployed, plus all database configuration, networking, and tagging.
# -----------------------------------------------------------------------------

# General naming
variable "name" {
  description = "Name prefix for the RDS instance or Aurora cluster"
  type        = string
}

# -------------------------------
# Engine selection & versions
# -------------------------------
variable "engine" {
  description = "RDS engine for a single-instance deployment (e.g., mysql, postgres)"
  type        = string
  default     = "postgres"
}

variable "engine_cluster" {
  description = "Aurora engine name (e.g., aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version" {
  description = "Version number for the standard RDS engine"
  type        = string
  default     = "14.7"
}

variable "engine_version_cluster" {
  description = "Version number for the Aurora engine"
  type        = string
  default     = "15.3"
}

# -------------------------------
# Instance sizing & counts
# -------------------------------
variable "instance_class" {
  description = "Instance class for RDS/Aurora instances (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage (GB) for standard RDS instance"
  type        = number
  default     = 20
}

variable "aurora_replica_count" {
  description = "Number of Aurora reader replicas"
  type        = number
  default     = 1
}

variable "aurora_instance_count" {
  description = "Total Aurora instances (1 primary + replicas)"
  type        = number
  default     = 2
}

# -------------------------------
# Database credentials & name
# -------------------------------
variable "db_name" {
  description = "Initial database name to create"
  type        = string
}

variable "username" {
  description = "Master username for the database"
  type        = string
}

variable "password" {
  description = "Master password for the database (sensitive)"
  type        = string
  sensitive   = true
}

# -------------------------------
# Networking
# -------------------------------
variable "vpc_id" {
  description = "VPC ID where RDS/Aurora will be deployed"
  type        = string
}

variable "subnet_private_ids" {
  description = "List of private subnet IDs for RDS/Aurora"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "List of public subnet IDs for RDS/Aurora (if public)"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Whether the DB instances should have public endpoints"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ for standard RDS instance"
  type        = bool
  default     = false
}

# -------------------------------
# Advanced options
# -------------------------------
variable "parameters" {
  description = "Custom DB engine parameters (map of name => value)"
  type        = map(string)
  default     = {}
}

variable "use_aurora" {
  description = "Toggle between Aurora cluster (true) and standard RDS (false)"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Key/value map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# -------------------------------
# Parameter group families
# -------------------------------
variable "parameter_group_family_aurora" {
  description = "Parameter group family string for Aurora (e.g., aurora-postgresql15)"
  type        = string
  default     = "aurora-postgresql15"
}

variable "parameter_group_family_rds" {
  description = "Parameter group family for standard RDS (e.g., postgres15)"
  type        = string
  default     = "postgres15"
}