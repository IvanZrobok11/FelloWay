variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "felloway"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "use_custom_domain" {
  type        = bool
  default     = false
  description = "false = CloudFront default URLs (no Route 53 / domain registration)."
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "Route 53 hosted zone apex; required when use_custom_domain is true."
}

variable "api_host" {
  type        = string
  default     = ""
  description = "API hostname; required when use_custom_domain is true."
}

variable "web_host" {
  type        = string
  default     = ""
  description = "Web hostname; required when use_custom_domain is true."
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "ecs_cpu" {
  type    = number
  default = 512
}

variable "ecs_memory" {
  type    = number
  default = 1024
}

variable "ecs_desired_count" {
  type    = number
  default = 1
}

variable "jwt_signing_key" {
  type      = string
  sensitive = true
}

variable "linkedin_client_id" {
  type        = string
  sensitive   = true
  description = "LinkedIn OAuth app client ID (stored in Secrets Manager felloway/{env}/app)."
}

variable "linkedin_client_secret" {
  type        = string
  sensitive   = true
  description = "LinkedIn OAuth app client secret."
}
