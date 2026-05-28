data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

module "network" {
  source       = "../../modules/network"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  aws_region   = var.aws_region
}

locals {
  admin_enabled    = var.admin_service_key != ""
  web_origin_url   = "https://${var.web_host}"
  api_public_url   = "https://${var.api_host}"
  admin_public_url = local.admin_enabled && var.admin_host != "" ? "https://${var.admin_host}" : ""
}

resource "aws_acm_certificate" "api" {
  domain_name               = var.api_host
  subject_alternative_names = var.admin_host != "" ? [var.admin_host] : []
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "api_cert" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for r in aws_route53_record.api_cert : r.fqdn]
}

resource "aws_acm_certificate" "web" {
  provider          = aws.us_east_1
  domain_name       = var.web_host
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "web_cert" {
  for_each = {
    for dvo in aws_acm_certificate.web.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "web" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.web.arn
  validation_record_fqdns = [for r in aws_route53_record.web_cert : r.fqdn]
}

module "alb" {
  source               = "../../modules/alb"
  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  security_group_id    = module.network.alb_security_group_id
  certificate_arn      = aws_acm_certificate_validation.api.certificate_arn
  create_admin_target_group = local.admin_enabled
  admin_listener_hosts      = var.admin_host != "" ? [var.admin_host] : []
}

module "rds" {
  source             = "../../modules/rds"
  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.network.private_subnet_ids
  security_group_id  = module.network.rds_security_group_id
  db_instance_class  = var.db_instance_class
}

resource "aws_secretsmanager_secret" "app" {
  name = "${var.project_name}/${var.environment}/app"
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    Jwt__SigningKey               = var.jwt_signing_key
    OAuth__LinkedIn__ClientId     = var.linkedin_client_id
    OAuth__LinkedIn__ClientSecret = var.linkedin_client_secret
    Stream__ApiKey                = var.stream_api_key
    Stream__ApiSecret             = var.stream_api_secret
    AdminAuth__Username           = var.admin_username
    AdminAuth__Password           = var.admin_password
    AdminAuth__ServiceKey         = var.admin_service_key
  })
}

module "ecs" {
  source                 = "../../modules/ecs"
  project_name           = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  private_subnet_ids     = module.network.private_subnet_ids
  security_group_id      = module.network.ecs_tasks_security_group_id
  target_group_arn       = module.alb.target_group_arn
  admin_target_group_arn = module.alb.admin_target_group_arn != null ? module.alb.admin_target_group_arn : module.alb.target_group_arn
  db_secret_arn          = module.rds.db_secret_arn
  app_secret_arn         = aws_secretsmanager_secret.app.arn
  web_origin_url         = local.web_origin_url
  api_base_url           = local.api_public_url
  cpu                    = var.ecs_cpu
  memory                 = var.ecs_memory
  desired_count          = var.ecs_desired_count
  enable_admin_service   = local.admin_enabled
}

module "web" {
  source              = "../../modules/web"
  project_name        = var.project_name
  environment         = var.environment
  web_domain          = var.web_host
  acm_certificate_arn = aws_acm_certificate_validation.web.certificate_arn
}

module "dns" {
  source                 = "../../modules/dns"
  zone_id                = data.aws_route53_zone.main.zone_id
  api_domain             = var.api_host
  web_domain             = var.web_host
  admin_domain           = var.admin_host
  alb_dns_name           = module.alb.alb_dns_name
  alb_zone_id            = module.alb.alb_zone_id
  cloudfront_domain_name = module.web.cloudfront_domain_name
  cloudfront_zone_id     = module.web.cloudfront_hosted_zone_id
}
