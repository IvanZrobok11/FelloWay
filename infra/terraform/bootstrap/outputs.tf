output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_lock_table" {
  value = aws_dynamodb_table.terraform_lock.name
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "github_deploy_role_arns" {
  value = { for k, r in aws_iam_role.github_deploy : k => r.arn }
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
