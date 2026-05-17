variable "project_name" { type = string }
variable "environment" { type = string }
variable "web_domain" { type = string }
variable "acm_certificate_arn" {
  type        = string
  description = "ACM cert in us-east-1 for CloudFront"
}
