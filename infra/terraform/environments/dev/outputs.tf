output "api_url" {
  value = "https://${var.api_host}"
}

output "web_url" {
  value = "https://${var.web_host}"
}

output "ecr_repository_url" {
  value = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.ecs.ecs_service_name
}

output "s3_web_bucket" {
  value = module.web.s3_bucket_name
}

output "cloudfront_distribution_id" {
  value = module.web.cloudfront_distribution_id
}

output "github_deploy_role_arn" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-github-deploy-${var.environment}"
}

data "aws_caller_identity" "current" {}
