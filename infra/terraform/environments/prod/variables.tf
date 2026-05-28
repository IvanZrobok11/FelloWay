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
  default = "prod"
}

variable "domain_name" {
  type        = string
  description = "Route 53 hosted zone apex (e.g. felloway.click)"
}

variable "api_host" {
  type = string
}

variable "web_host" {
  type = string
}

variable "admin_host" {
  type        = string
  default     = ""
  description = "Admin panel hostname (e.g. admin.example.com)."
}

variable "admin_username" {
  type      = string
  sensitive = true
  default   = ""
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "admin_service_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.small"
}

variable "ecs_cpu" {
  type    = number
  default = 512
}

variable "ecs_memory" {
  type    = number
  default = 2048
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

variable "stream_api_key" {
  type        = string
  sensitive   = true
  description = "GetStream public API key (same value as PROD_STREAM_API_KEY in GitHub)."
}

variable "stream_api_secret" {
  type        = string
  sensitive   = true
  description = "GetStream API secret (server-only)."
}
