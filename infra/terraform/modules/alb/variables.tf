variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "enable_https" {
  type        = bool
  default     = true
  description = "When false, forward HTTP:80 only (technical / no ACM on ALB)."
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "Required when enable_https is true."
}
variable "target_port" {
  type    = number
  default = 8080
}
variable "create_admin_target_group" {
  type        = bool
  default     = false
  description = "Create ALB target group for felloway-admin ECS service."
}

variable "admin_listener_hosts" {
  type        = list(string)
  default     = []
  description = "Host header values that forward to admin target group (custom domain)."
}
