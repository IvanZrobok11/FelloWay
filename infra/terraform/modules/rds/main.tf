resource "random_password" "db" {
  length  = 24
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}/${var.environment}/database"
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-${var.environment}"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false
  skip_final_snapshot    = var.environment != "prod"
  storage_encrypted      = true

  tags = {
    Name = "${var.project_name}-${var.environment}-rds"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username       = var.db_username
    password       = random_password.db.result
    host           = aws_db_instance.main.address
    port           = aws_db_instance.main.port
    dbname         = var.db_name
    connection_string = "Host=${aws_db_instance.main.address};Port=${aws_db_instance.main.port};Database=${var.db_name};Username=${var.db_username};Password=${random_password.db.result}"
  })
}
