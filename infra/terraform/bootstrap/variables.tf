variable "aws_region" {
  type        = string
  description = "Primary AWS region for state bucket and resources"
  default     = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "felloway"
}

variable "github_repository" {
  type        = string
  description = "GitHub repo in org/name form for OIDC trust"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state"
}
