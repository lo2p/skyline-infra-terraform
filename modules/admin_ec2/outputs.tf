output "instance_id" {
  description = "Admin EC2 instance ID."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Admin EC2 public IP."
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Admin EC2 private IP."
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Admin EC2 security group ID."
  value       = aws_security_group.this.id
}

output "role_arn" {
  description = "Admin EC2 IAM role ARN."
  value       = aws_iam_role.this.arn
}
