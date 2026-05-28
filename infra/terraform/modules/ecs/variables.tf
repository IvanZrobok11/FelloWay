variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "db_secret_arn" { type = string }
variable "app_secret_arn" { type = string }
variable "web_origin_url" { type = string }
variable "cpu" {
  type    = number
  default = 512
}
variable "memory" {
  type    = number
  default = 1024
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "container_image" {
  type        = string
  description = "Initial image; CI updates task definition"
  default     = "public.ecr.aws/docker/library/nginx:alpine"
}
variable "admin_container_image" {
  type        = string
  description = "Initial admin image; CI updates task definition"
  default     = "public.ecr.aws/docker/library/nginx:alpine"
}
variable "admin_target_group_arn" {
  type        = string
  description = "ALB target group for admin service"
  default     = ""
}
variable "api_base_url" {
  type        = string
  description = "Same-environment API base URL for admin server-side calls"
  default     = ""
}
variable "enable_admin_service" {
  type    = bool
  default = true
}
variable "admin_cpu" {
  type    = number
  default = 256
}
variable "admin_memory" {
  type    = number
  default = 512
}
variable "admin_desired_count" {
  type    = number
  default = 1
}
