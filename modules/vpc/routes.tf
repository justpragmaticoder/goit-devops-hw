#------------------------------------------------------------------------------
# Route table that governs traffic for the publicly routable subnets
#------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  # Attach the route table to the VPC

  tags = {
    # Tag helps you spot the table quickly in the AWS console
    Name = "${var.vpc_name}-public-rt"
  }
}

#------------------------------------------------------------------------------
# Default route: send all outbound traffic (0.0.0.0/0) to the Internet Gateway
# so instances in the public subnets have Internet access
#------------------------------------------------------------------------------
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id      # Route table to update
  destination_cidr_block = "0.0.0.0/0"                    # Catch-all IP range
  gateway_id             = aws_internet_gateway.igw.id    # Target Internet Gateway
}

#------------------------------------------------------------------------------
# Associate the public route table with every subnet defined in var.public_subnets
# so each subnet inherits the IGW route and becomes Internet-facing
#------------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)             # One association per subnet
  subnet_id      = aws_subnet.public[count.index].id      # Current subnet ID
  route_table_id = aws_route_table.public.id              # Route table to attach
}