# Routes admin CloudFront hostname to admin target group (technical URLs only).

resource "aws_lb_listener_rule" "admin_technical" {
  count = !var.use_custom_domain && local.admin_enabled ? 1 : 0

  listener_arn = module.alb.http_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = module.alb.admin_target_group_arn
  }

  condition {
    host_header {
      values = [module.admin_cdn[0].distribution_domain_name]
    }
  }
}
