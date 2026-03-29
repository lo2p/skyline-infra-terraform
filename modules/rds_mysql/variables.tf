variable "vpc_id" {
  description = "VPC ID for the database resources."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private subnet IDs used for the DB subnet group."
  type        = list(string)
}

variable "worker_node_security_group_id" {
  description = "Security group ID used by EKS worker nodes."
  type        = string
}

variable "admin_security_group_id" {
  description = "Security group ID used by the admin EC2 instance."
  type        = string
}

variable "parameter_store_prefix" {
  description = "Prefix for SSM parameter paths."
  type        = string
}

variable "db_name" {
  description = "Application database name."
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
}
