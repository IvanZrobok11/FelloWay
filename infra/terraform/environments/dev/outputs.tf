output "api_url" {
  value       = local.api_public_url
  description = "Public API base URL (no trailing slash)."
}

output "web_url" {
  value       = local.web_origin_url
  description = "Public Flutter web URL."
}

output "use_custom_domain" {
  value = var.use_custom_domain
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

output "api_cloudfront_distribution_id" {
  value       = var.use_custom_domain ? null : module.api_cdn[0].distribution_id
  description = "Set DEV_API_CLOUDFRONT_DISTRIBUTION_ID in GitHub if using technical URLs."
}

output "github_deploy_role_arn" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-github-deploy-${var.environment}"
}

data "aws_caller_identity" "current" {}
