resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-api-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = var.environment != "prod"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}-api-${var.environment}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.project_name}-${var.environment}-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_secrets" {
  name = "${var.project_name}-${var.environment}-secrets"
  role = aws_iam_role.execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [var.db_secret_arn, var.app_secret_arn]
    }]
  })
}

resource "aws_iam_role" "task" {
  name               = "${var.project_name}-${var.environment}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name  = "api"
    image = var.container_image
    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
    }]
    environment = [
      { name = "ASPNETCORE_ENVIRONMENT", value = var.environment },
      { name = "ASPNETCORE_URLS", value = "http://+:8080" },
      { name = "Cors__AllowedOrigins__0", value = var.web_origin_url },
      { name = "Frontend__BaseUrl", value = var.web_origin_url },
    ]
    secrets = [
      {
        name      = "ConnectionStrings__Default"
        valueFrom = "${var.db_secret_arn}:connection_string::"
      },
      {
        name      = "Jwt__SigningKey"
        valueFrom = "${var.app_secret_arn}:Jwt__SigningKey::"
      },
      {
        name      = "OAuth__LinkedIn__ClientId"
        valueFrom = "${var.app_secret_arn}:OAuth__LinkedIn__ClientId::"
      },
      {
        name      = "OAuth__LinkedIn__ClientSecret"
        valueFrom = "${var.app_secret_arn}:OAuth__LinkedIn__ClientSecret::"
      },
      {
        name      = "Stream__ApiKey"
        valueFrom = "${var.app_secret_arn}:Stream__ApiKey::"
      },
      {
        name      = "Stream__ApiSecret"
        valueFrom = "${var.app_secret_arn}:Stream__ApiSecret::"
      },
      {
        name      = "AdminAuth__ServiceKey"
        valueFrom = "${var.app_secret_arn}:AdminAuth__ServiceKey::"
      },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.api.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "api"
      }
    }
    essential = true
  }])
}

resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-api-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "api"
    container_port   = 8080
  }

  health_check_grace_period_seconds = 120

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
