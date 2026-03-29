variable "vpc_id" {
  description = "VPC ID for the cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster and node group."
  type        = list(string)
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint."
  type        = list(string)
}

variable "parameter_store_prefix" {
  description = "Prefix for application configuration stored in AWS Systems Manager Parameter Store."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
}
