# ------------------------------------------------------------------------------
# S3 bucket that stores the Terraform state file
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  # Bucket name is passed in via module/variable input
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Terraform State Bucket"  # Helps identify the bucket in the AWS console
    Environment = "lesson-7"                # Project or environment tag
  }
}

# ------------------------------------------------------------------------------
# Enable versioning so every change to terraform.tfstate is preserved.
# This lets you roll back the state file if it ever gets corrupted.
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"  # Turn on S3 versioning (creates a new object version on every write)
  }
}

# ------------------------------------------------------------------------------
# Enforce that the bucket owner (your AWS account) always owns objects
# written to the bucket, even if they come from a different account or IAM role.
# This avoids ACL-related permission issues when multiple pipelines or users push.
# ------------------------------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "terraform_state_ownership" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"  # Disable ACLs; bucket owner owns all objects
  }
}