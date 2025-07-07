# ---------------------------------------------------------------------------
# Network layout variables
# ---------------------------------------------------------------------------
variable "vpc_cidr_block" {
  # The IPv4 CIDR block that defines the address space for the VPC
  # (e.g. 10.0.0.0/16). Choose a range that does not overlap with any
  # on-prem or other VPC networks you plan to peer with.
  description = "IPv4 CIDR block to assign to the VPC (e.g. 10.0.0.0/16)"
  type        = string
}

variable "public_subnets" {
  # A list of IPv4 CIDR blocks—one per Availability Zone—that will become
  # publicly routed subnets (i.e., subnets whose route table points to an
  # Internet Gateway). Instances launched here can receive public IPs.
  description = "List of CIDR blocks for Internet-facing (public) subnets"
  type        = list(string)
}

variable "private_subnets" {
  # A list of IPv4 CIDR blocks for private subnets that have no direct
  # Internet route. Typical use cases are application servers, databases,
  # or internal services that should stay unreachable from the public web.
  description = "List of CIDR blocks for isolated (private) subnets"
  type        = list(string)
}

variable "availability_zones" {
  # The AWS Availability Zones (e.g. ["us-west-2a", "us-west-2b"]) across
  # which the public and private subnets will be distributed. The number
  # of elements in this list should match the length of both subnet lists.
  description = "Availability Zones in which to create the subnets"
  type        = list(string)
}

variable "vpc_name" {
  # Human-readable name tag applied to the VPC and propagated to related
  # resources for easy identification in the AWS console and CLI.
  description = "Name tag to apply to the VPC"
  type        = string
}