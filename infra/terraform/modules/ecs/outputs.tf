output "ecr_repository_url" { value = aws_ecr_repository.api.repository_url }
output "admin_ecr_repository_url" { value = aws_ecr_repository.admin.repository_url }
output "cluster_name" { value = aws_ecs_cluster.main.name }
output "api_service_name" { value = aws_ecs_service.api.name }
output "admin_service_name" { value = var.enable_admin_service ? aws_ecs_service.admin[0].name : null }
output "ecs_cluster_name" { value = aws_ecs_cluster.main.name }
output "ecs_service_name" { value = aws_ecs_service.api.name }
output "task_definition_family" { value = aws_ecs_task_definition.api.family }
