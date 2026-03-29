variable "vpc_id" {
  description = "VPC ID where private network resources should be created."
  type        = string
}

variable "availability_zones" {
  description = "Two availability zones used by the demo."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Provide exactly two availability zones."
  }
}

variable "public_subnet_id_for_nat" {
  description = "Public subnet ID that should host the NAT gateway."
  type        = string
}

variable "private_eks_subnet_cidrs" {
  description = "Two CIDR blocks for private EKS subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_eks_subnet_cidrs) == 2
    error_message = "Provide exactly two private EKS subnet CIDR blocks."
  }
}

variable "private_db_subnet_cidrs" {
  description = "Two CIDR blocks for private DB subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_cidrs) == 2
    error_message = "Provide exactly two private DB subnet CIDR blocks."
  }
}

variable "cluster_name" {
  description = "EKS cluster name used for subnet tagging."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
}
