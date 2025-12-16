output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "app_security_group_id" {
  description = "Application security group ID"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.postgres.db_name
}

output "ec2_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.app.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}