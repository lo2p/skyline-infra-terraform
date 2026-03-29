variable "aws_region" {
  description = "AWS region for the demo environment."
  type        = string
  default     = "ap-northeast-2"
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

variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the EKS public endpoint when enabled."
  type        = list(string)
  default     = []
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

variable "persistent_state_bucket" {
  description = "S3 bucket that stores the persistent root Terraform state."
  type        = string
  default     = "skyline-terraform"
}

variable "persistent_state_key" {
  description = "S3 key for the persistent root Terraform state."
  type        = string
  default     = "skyline-infra-terraform/persistent/terraform.tfstate"
}

variable "persistent_state_region" {
  description = "AWS region that stores the persistent root Terraform state."
  type        = string
  default     = "ap-northeast-2"
}
