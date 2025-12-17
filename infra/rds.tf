# DB Subnet Group - Use PUBLIC subnets for publicly accessible RDS
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group-v2"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier           = "${var.project_name}-v2"  # Changed identifier to force recreation
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = var.db_instance_class
  allocated_storage    = 20
  storage_type         = "gp3"
  storage_encrypted    = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = true
  skip_final_snapshot = true

  backup_retention_period = 0
  maintenance_window      = "mon:04:00-mon:05:00"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
