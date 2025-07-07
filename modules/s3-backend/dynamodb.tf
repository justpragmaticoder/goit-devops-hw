# ---------------------------------------------------------------------------
# DynamoDB table used by Terraform’s remote-state backend to acquire a lock
# before it reads or writes the state file in S3.  A single item is created
# whose partition key (hash_key) is “LockID”; if the item already exists,
# Terraform knows another process is running and will wait or exit.  Using
# PAY_PER_REQUEST keeps costs near zero for infrequent operations.
# ---------------------------------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name          # Table name (passed in via variable)
  billing_mode = "PAY_PER_REQUEST"                # On-demand throughput
  hash_key     = "LockID"                         # Partition key

  attribute {
    name = "LockID"
    type = "S"                                    # String attribute
  }

  tags = {
    Name        = "Terraform Lock Table"          # Helps identify the table in the console
    Environment = "lesson-5"                      # Project or environment tag
  }
}