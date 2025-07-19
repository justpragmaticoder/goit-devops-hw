# -----------------------------------------------------------------------------
# Amazon Aurora Serverless / Provisioned Cluster
# -----------------------------------------------------------------------------
# This module provisions an Aurora cluster, a primary writer instance, and the
# desired number of reader replicas, all configurable through input variables.
# It also attaches a custom parameter group and applies standard tags.
# -----------------------------------------------------------------------------

# -------------------------------
# Aurora DB Cluster definition
# -------------------------------
resource "aws_rds_cluster" "aurora" {
  count = var.use_aurora ? 1 : 0                       # Create cluster only if Aurora is enabled

  cluster_identifier              = "${var.name}-cluster"   # Unique cluster name
  engine                          = var.engine_cluster      # Aurora engine type (e.g., aurora-mysql, aurora-postgresql)
  engine_version                  = var.engine_version_cluster # Specific Aurora engine version

  # Master (root) credentials and default database name
  master_username = var.username
  master_password = var.password
  database_name   = var.db_name

  # Network and security
  db_subnet_group_name   = aws_db_subnet_group.default.name  # Subnet group for multi-AZ deployment
  vpc_security_group_ids = [aws_security_group.rds.id]       # RDS security group

  # Backup & snapshot settings
  backup_retention_period   = var.backup_retention_period    # Days to retain automated backups
  skip_final_snapshot       = false                          # Always take a final snapshot before destroy
  final_snapshot_identifier = "${var.name}-final-snapshot"   # Final snapshot name

  # Attach custom cluster-level parameter group
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name

  tags = var.tags                                            # Standard tags
}

# -------------------------------
# Primary (writer) instance
# -------------------------------
resource "aws_rds_cluster_instance" "aurora_writer" {
  count              = var.use_aurora ? 1 : 0

  identifier         = "${var.name}-writer"                # Instance identifier
  cluster_identifier = aws_rds_cluster.aurora[0].id         # Associate with the above cluster
  instance_class     = var.instance_class                   # e.g., db.r6g.large
  engine             = var.engine_cluster                  # Must match cluster engine

  # Networking
  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible  = var.publicly_accessible            # Allow public access if true

  tags = var.tags
}

# -------------------------------
# Reader replica instances
# -------------------------------
resource "aws_rds_cluster_instance" "aurora_readers" {
  count              = var.use_aurora ? var.aurora_replica_count : 0

  identifier         = "${var.name}-reader-${count.index}" # Each reader gets a unique suffix
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = var.engine_cluster

  db_subnet_group_name = aws_db_subnet_group.default.name
  publicly_accessible  = var.publicly_accessible

  tags = var.tags
}

# -------------------------------
# Custom Aurora cluster parameter group
# -------------------------------
resource "aws_rds_cluster_parameter_group" "aurora" {
  count = var.use_aurora ? 1 : 0

  name        = "${var.name}-aurora-params"                # Parameter group name
  family      = var.parameter_group_family_aurora           # e.g., aurora-mysql8.0, aurora-postgresql15
  description = "Aurora PG for ${var.name}"

  # Iterate through the map variable `parameters` to set custom parameters
  dynamic "parameter" {
    for_each = var.parameters                                # Map of { name = value }
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"                       # Apply after next reboot
    }
  }

  tags = var.tags
}