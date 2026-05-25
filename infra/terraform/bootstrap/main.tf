data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # SHA-1 thumbprints (40 hex chars each) for GitHub OIDC intermediates — see
  # https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

locals {
  deploy_environments = ["dev", "test", "prod"]
}

data "aws_iam_policy_document" "github_deploy" {
  for_each = toset(local.deploy_environments)

  statement {
    sid    = "EcrPushPull"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EcsDeploy"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3WebSync"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudFrontInvalidate"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SecretsRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "github_assume" {
  for_each = toset(local.deploy_environments)

  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:${each.key}"]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  for_each = toset(local.deploy_environments)

  name               = "${var.project_name}-github-deploy-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.github_assume[each.key].json
}

resource "aws_iam_role_policy" "github_deploy" {
  for_each = toset(local.deploy_environments)

  name   = "${var.project_name}-github-deploy-${each.key}"
  role   = aws_iam_role.github_deploy[each.key].id
  policy = data.aws_iam_policy_document.github_deploy[each.key].json
}
