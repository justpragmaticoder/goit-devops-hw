# -----------------------------------------------------------------------------
# Shared Resources for RDS / Aurora
# -----------------------------------------------------------------------------
# This file contains components that are common to both a standard RDS instance
# and an Aurora cluster: a DB subnet group and a dedicated security group.
# -----------------------------------------------------------------------------

# -------------------------------
# DB Subnet Group
# -------------------------------
# Provides the list of subnets where RDS/Aurora will create ENIs. For public
# instances we attach public subnets; otherwise we use private subnets.
resource "aws_db_subnet_group" "default" {
  name = "${var.name}-subnet-group"                        # Subnet group name

  # Choose subnet IDs based on public/private flag
  subnet_ids = var.publicly_accessible ? var.subnet_public_ids : var.subnet_private_ids

  tags = var.tags                                           # Standard tags
}

# -------------------------------
# Security Group for database traffic
# -------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.name}-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  # Inbound rules (PostgreSQL default port 5432)
  ingress {
    from_port   = 5432                                      # Allow PostgreSQL connections
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                            # TODO: Restrict to trusted CIDRs
  }

  # Outbound rules (allow all egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}