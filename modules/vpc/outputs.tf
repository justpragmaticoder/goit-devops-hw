# ------------------------------------------------------------------------------
# Outputs that expose the key network resource IDs created by this module
# ------------------------------------------------------------------------------

output "vpc_id" {
  # Unique identifier (vpc-xxxxxxxx) of the VPC provisioned by this module.
  # Pass this value to other modules or scripts that need to attach resources
  # (gateways, security groups, subnets, etc.) to the same VPC.
  description = "ID of the Amazon VPC created by this module"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  # List of subnet IDs (subnet-xxxxxxxx) for the publicly routed subnets—
  # i.e., subnets associated with a route table that contains a route to an
  # Internet Gateway. Use these IDs when launching EC2 instances that need
  # public IPs or when configuring load balancers, NAT gateways, and similar
  # Internet-facing resources.
  description = "List of subnet IDs for the public (internet-routable) subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  # List of subnet IDs (subnet-xxxxxxxx) for the private subnets, which have
  # no direct route to the Internet. Ideal for application tiers, databases,
  # and other internal services that should remain isolated from public traffic.
  description = "List of subnet IDs for the private (non-internet-routable) subnets"
  value       = aws_subnet.private[*].id
}