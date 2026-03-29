variable "aws_region" {
  description = "AWS region for the demo environment."
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Two CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDR blocks."
  }
}

variable "private_eks_subnet_cidrs" {
  description = "Two CIDR blocks for private EKS subnets."
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]

  validation {
    condition     = length(var.private_eks_subnet_cidrs) == 2
    error_message = "Provide exactly two private EKS subnet CIDR blocks."
  }
}

variable "private_db_subnet_cidrs" {
  description = "Two CIDR blocks for private DB subnets."
  type        = list(string)
  default     = ["10.20.20.0/24", "10.20.21.0/24"]

  validation {
    condition     = length(var.private_db_subnet_cidrs) == 2
    error_message = "Provide exactly two private DB subnet CIDR blocks."
  }
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name for the admin instance."
  type        = string
}

variable "admin_access_cidr" {
  description = "CIDR block allowed to SSH to the admin EC2 instance."
  type        = string
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the EKS public endpoint."
  type        = list(string)
}

variable "parameter_store_prefix" {
  description = "Prefix for demo parameters stored in AWS Systems Manager Parameter Store."
  type        = string
  default     = "/skyline-system-demo/demo"
}

variable "db_name" {
  description = "Name of the application database."
  type        = string
  default     = "skylineapp"
}

variable "db_username" {
  description = "Master username for the demo MySQL instance."
  type        = string
  default     = "skylineadmin"
}

variable "existing_ecr_repository_name" {
  description = "Name of the existing ECR repository used for the demo application image."
  type        = string
  default     = "skyline"
}
