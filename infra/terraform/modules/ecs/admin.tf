resource "aws_ecr_repository" "admin" {
  name                 = "${var.project_name}-admin-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = var.environment != "prod"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "admin" {
  name              = "/ecs/${var.project_name}-admin-${var.environment}"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "admin" {
  family                   = "${var.project_name}-admin-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.admin_cpu
  memory                   = var.admin_memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name  = "admin"
    image = var.admin_container_image
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]
    environment = [
      { name = "ASPNETCORE_ENVIRONMENT", value = var.environment },
      { name = "ASPNETCORE_URLS", value = "http://+:8080" },
      { name = "Api__BaseUrl", value = var.api_base_url },
    ]
    secrets = [
      {
        name      = "AdminAuth__Username"
        valueFrom = "${var.app_secret_arn}:AdminAuth__Username::"
      },
      {
        name      = "AdminAuth__Password"
        valueFrom = "${var.app_secret_arn}:AdminAuth__Password::"
      },
      {
        name      = "AdminAuth__ServiceKey"
        valueFrom = "${var.app_secret_arn}:AdminAuth__ServiceKey::"
      },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.admin.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "admin"
      }
    }
    essential = true
  }])
}

resource "aws_ecs_service" "admin" {
  count = var.enable_admin_service ? 1 : 0

  name            = "${var.project_name}-admin-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.admin.arn
  desired_count   = var.admin_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.admin_target_group_arn
    container_name   = "admin"
    container_port   = 8080
  }

  health_check_grace_period_seconds = 120

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
