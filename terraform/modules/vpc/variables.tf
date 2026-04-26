############################################################################
# VPC Module - Input Variables 
############################################################################
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default = "10.0.0.0/16"
  }

variable "cluster_name" {
  description = "Name of the EKS cluster - use to tag subnets"
  type        = string
}

variable "environment" {
  description = "Environment name e.g. dev, staging, prod"
  type        = string
}

# ---------Tags-------------------------------------------------------------------------
variable "tags" {
  description = "Map of strings to apply to all resources"
  type        = map(string)
  default     = {}
}