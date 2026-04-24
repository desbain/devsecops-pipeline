variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "devsecops-cluster"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "devsecops-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}
