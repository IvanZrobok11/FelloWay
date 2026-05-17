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
