variable "ecr_name" {
  # Name that will be assigned to the Amazon ECR repository.
  # This becomes part of the repository URI
  # (e.g. 123456789012.dkr.ecr.us-west-2.amazonaws.com/<ecr_name>).
  # Must be 2–256 characters, lowercase letters, numbers, hyphens, or underscores.
  description = "Name to assign to the Amazon ECR repository (lowercase letters, numbers, hyphens, and underscores only)"
  type        = string
}

variable "scan_on_push" {
  # Enables or disables the “image scan on push” feature.
  # When set to true, every image pushed to the repository is automatically
  # scanned for vulnerabilities by Amazon ECR (powered by Amazon Inspector/GuardDuty).
  # When false, no automatic scanning occurs, and you must trigger scans manually.
  description = "Whether to enable automatic vulnerability scanning each time an image is pushed to the repository"
  type        = bool
}