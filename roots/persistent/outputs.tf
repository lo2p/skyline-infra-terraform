output "vpc_id" {
  description = "VPC ID shared with the ephemeral workload plane."
  value       = module.network_public.vpc_id
}

output "availability_zones" {
  description = "Availability zones used by the environment."
  value       = module.network_public.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the bastion and NAT gateway."
  value       = module.network_public.public_subnet_ids
}

output "cluster_name" {
  description = "Stable EKS cluster name used by the environment."
  value       = local.cluster_name
}

output "load_balancer_controller_role_name" {
  description = "Stable IAM role name reserved for the AWS Load Balancer Controller."
  value       = local.load_balancer_controller_role_name
}

output "external_secrets_role_name" {
  description = "Stable IAM role name reserved for the External Secrets service account."
  value       = local.external_secrets_role_name
}

output "common_tags" {
  description = "Common tags shared with the ephemeral workload plane."
  value       = local.common_tags
}

output "admin_instance_id" {
  description = "Admin EC2 instance ID."
  value       = module.admin_ec2.instance_id
}

output "admin_instance_public_ip" {
  description = "Admin EC2 public IP address."
  value       = module.admin_ec2.public_ip
}

output "admin_instance_private_ip" {
  description = "Admin EC2 private IP address."
  value       = module.admin_ec2.private_ip
}

output "admin_security_group_id" {
  description = "Admin EC2 security group ID."
  value       = module.admin_ec2.security_group_id
}

output "admin_role_arn" {
  description = "Admin EC2 IAM role ARN."
  value       = module.admin_ec2.role_arn
}

output "ecr_repository_name" {
  description = "Existing ECR repository name for the demo application."
  value       = data.aws_ecr_repository.existing.name
}

output "ecr_repository_url" {
  description = "Existing ECR repository URL for image push operations."
  value       = data.aws_ecr_repository.existing.repository_url
}
