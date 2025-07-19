# -----------------------------------------------------------------------------
# Standard (Single-Instance) Amazon RDS Deployment
# -----------------------------------------------------------------------------
# This file provisions a standalone RDS instance when Aurora is disabled. It
# also attaches a custom DB parameter group for fine-tuning engine behaviour.
# -----------------------------------------------------------------------------

# -------------------------------
# Stand-Alone RDS Instance
# -------------------------------
resource "aws_db_instance" "standard" {
  count  = var.use_aurora ? 0 : 1                       # Create only if Aurora is NOT used

  identifier         = var.name                         # RDS instance identifier
  engine             = var.engine                       # e.g., mysql, postgres
  engine_version     = var.engine_version               # Specific RDS engine version
  instance_class     = var.instance_class               # e.g., db.t4g.medium
  allocated_storage  = var.allocated_storage            # Storage size in GB

  # Initial DB and master credentials
  db_name  = var.db_name
  username = var.username
  password = var.password

  # Networking & security
  db_subnet_group_name   = aws_db_subnet_group.default.name   # Subnet group for multi-AZ spread
  vpc_security_group_ids = [aws_security_group.rds.id]        # Attach RDS SG
  multi_az               = var.multi_az                      # Enable HA in multiple AZs
  publicly_accessible    = var.publicly_accessible           # Expose publicly if true

  # Backup & maintenance
  backup_retention_period = var.backup_retention_period
  parameter_group_name    = aws_db_parameter_group.standard[0].name # Attach custom PG

  tags = var.tags                                            # Standard tags
}

# -------------------------------
# Custom Parameter Group for RDS
# -------------------------------
resource "aws_db_parameter_group" "standard" {
  count = var.use_aurora ? 0 : 1

  name        = "${var.name}-rds-params"                # PG name
  family      = var.parameter_group_family_rds           # e.g., mysql8.0, postgres15
  description = "Standard RDS PG for ${var.name}"

  # Iterate through map variable `parameters` to set engine parameters
  dynamic "parameter" {
    for_each = var.parameters                              # Map of { name = value }
    content {
      name         = parameter.key
      value        = parameter.value
      apply_method = "pending-reboot"                     # Apply after next reboot
    }
  }

  tags = var.tags
}