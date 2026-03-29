variable "vpc_cidr" {
  description = "CIDR block for the VPC."
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

variable "public_subnet_cidrs" {
  description = "Two CIDR blocks for public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDR blocks."
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
