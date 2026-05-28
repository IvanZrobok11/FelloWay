variable "zone_id" { type = string }
variable "api_domain" { type = string }
variable "web_domain" { type = string }
variable "alb_dns_name" { type = string }
variable "alb_zone_id" { type = string }
variable "cloudfront_domain_name" { type = string }
variable "cloudfront_zone_id" { type = string }
variable "admin_domain" {
  type        = string
  default     = ""
  description = "Admin panel hostname (ALB alias)"
}
