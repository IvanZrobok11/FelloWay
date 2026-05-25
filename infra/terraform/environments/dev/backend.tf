terraform {
  backend "s3" {
    bucket  = "felloway-terraform-state-bucket"
    key     = "felloway/dev"
    region  = "eu-central-1"
    encrypt = true
  }
}