output "endpoint" {
  description = "RDS endpoint address."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Application database name."
  value       = var.db_name
}

output "parameter_names" {
  description = "SSM parameter names containing database connection values."
  value = {
    host     = aws_ssm_parameter.db_host.name
    port     = aws_ssm_parameter.db_port.name
    name     = aws_ssm_parameter.db_name.name
    username = aws_ssm_parameter.db_username.name
    password = aws_ssm_parameter.db_password.name
  }
}
