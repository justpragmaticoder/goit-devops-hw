terraform {
  backend "s3" {
    bucket         = "vasyl-p-lesson-7" # Name of the S3 bucket
    key            = "lesson-7/terraform.tfstate"        # Path to the state file
    region         = "us-west-2"                         # AWS region
    dynamodb_table = "terraform-locks"                   # Name of the DynamoDB table
    encrypt        = true                                # Encrypt the state file
  }
}