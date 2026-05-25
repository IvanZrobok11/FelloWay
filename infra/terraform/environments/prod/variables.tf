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
