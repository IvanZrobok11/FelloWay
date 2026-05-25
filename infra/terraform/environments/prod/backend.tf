terraform {
  backend "s3" {
    # Configure after bootstrap: bucket, region
    key     = "felloway/prod"
    encrypt = true
  }
}
