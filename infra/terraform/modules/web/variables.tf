variable "project_name" { type = string }
variable "environment" { type = string }

variable "use_custom_domain" {
  type        = bool
  default     = true
  description = "When false, use CloudFront default certificate (no custom alias)."
}

variable "web_domain" {
  type        = string
  default     = ""
  description = "Custom hostname; required when use_custom_domain is true."
}

variable "acm_certificate_arn" {
  type        = string
  default     = null
  description = "ACM cert in us-east-1 for CloudFront; required when use_custom_domain is true."
}
