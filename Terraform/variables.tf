variable "aws_region" {
  description = "The AWS region to deploy the infrastructure in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "grocersave"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.28"
}

variable "ecr_repository_names" {
  description = "A list of ECR repository names to create."
  type        = list(string)
  default = [
    "frontend",
    "bff-service",
    "auth-service",
    "catalog-service",
    "price-service"
  ]
}

variable "eks_cluster_role_arn" {
  description = "The ARN of the IAM role for the EKS cluster provided by AWS Academy."
  type        = string
}

variable "eks_node_group_role_arn" {
  description = "The ARN of the IAM role for the EKS node group provided by AWS Academy."
  type        = string
}
