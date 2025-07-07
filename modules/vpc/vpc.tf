# ------------------------------------------------------------------------------
# Primary VPC for this environment
# - The CIDR block defines the address space (e.g. 10.0.0.0/16).
# - DNS support / hostnames are enabled so EC2 instances get internal
#   DNS names (ip-10-0-1-5.us-west-2.compute.internal) and can resolve
#   AWS service endpoints by name.
# ------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block   # e.g. 10.0.0.0/16
  enable_dns_support   = true                 # Allow DNS resolution inside the VPC
  enable_dns_hostnames = true                 # Give instances DNS hostnames

  tags = {
    Name = "${var.vpc_name}-vpc"              # Tag helps locate the VPC in the console
  }
}

# ------------------------------------------------------------------------------
# Public subnets (one per Availability Zone)
# - Instances launched here automatically receive public IPs and can reach
#   the Internet via the Internet Gateway.
# ------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)          # Create N subnets
  vpc_id                  = aws_vpc.main.id                     # Attach to the VPC
  cidr_block              = var.public_subnets[count.index]     # CIDR for this subnet
  availability_zone       = var.availability_zones[count.index] # Distribute across AZs
  map_public_ip_on_launch = true                                # Auto-assign public IPs

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"   # e.g. myapp-public-subnet-1
  }
}

# ------------------------------------------------------------------------------
# Private subnets (no direct Internet route)
# - Suitable for app servers, databases, and other internal services that
#   should remain unreachable from the public Internet.
# ------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  }
}

# ------------------------------------------------------------------------------
# Internet Gateway
# - Provides a target in the public route table so instances in public subnets
#   can send and receive traffic to/from the Internet.
# ------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}