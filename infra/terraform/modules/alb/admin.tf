resource "aws_lb_target_group" "admin" {
  count = var.enable_admin_routing ? 1 : 0

  name        = "${var.project_name}-${var.environment}-admin"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-admin-tg"
  }
}

resource "aws_lb_listener_rule" "admin" {
  count = var.enable_admin_routing ? 1 : 0

  listener_arn = var.enable_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http_forward[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin[0].arn
  }

  condition {
    host_header {
      values = [var.admin_host]
    }
  }
}
