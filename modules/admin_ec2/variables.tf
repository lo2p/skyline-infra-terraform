variable "vpc_id" {
  description = "VPC ID for the admin instance."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the admin instance."
  type        = string
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name."
  type        = string
}

variable "admin_access_cidr" {
  description = "CIDR block allowed to SSH to the admin instance."
  type        = string
}

variable "parameter_store_prefix" {
  description = "Prefix for SSM parameter paths."
  type        = string
}

variable "ecr_repository_arn" {
  description = "ECR repository ARN for scoped push and pull access."
  type        = string
}

variable "aws_region" {
  description = "AWS region where the admin instance and EKS cluster are deployed."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name to configure kubeconfig for on the admin instance."
  type        = string
}

variable "load_balancer_controller_role_arn" {
  description = "Optional IAM role ARN used by the AWS Load Balancer Controller service account."
  type        = string
  default     = ""
}

variable "load_balancer_controller_role_name" {
  description = "Optional IAM role name used by the AWS Load Balancer Controller service account."
  type        = string
  default     = ""
}

variable "external_secrets_role_arn" {
  description = "Optional IAM role ARN used by the External Secrets service account."
  type        = string
  default     = ""
}

variable "external_secrets_role_name" {
  description = "Optional IAM role name used by the External Secrets service account."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
}
