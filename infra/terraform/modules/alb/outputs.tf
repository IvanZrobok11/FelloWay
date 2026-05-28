output "alb_arn" { value = aws_lb.main.arn }
output "alb_dns_name" { value = aws_lb.main.dns_name }
output "alb_zone_id" { value = aws_lb.main.zone_id }
output "target_group_arn" { value = aws_lb_target_group.api.arn }
output "admin_target_group_arn" {
  value = length(aws_lb_target_group.admin) > 0 ? aws_lb_target_group.admin[0].arn : null
}

output "http_listener_arn" {
  value = var.enable_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http_forward[0].arn
}
