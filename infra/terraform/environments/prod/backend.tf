terraform {
  backend "s3" {
    # Configure after bootstrap: bucket, key, region, dynamodb_table
    key            = "felloway/prod"
    encrypt        = true
    dynamodb_table = "felloway-terraform-lock"
  }
}
