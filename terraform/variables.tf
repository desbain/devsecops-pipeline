# ##############################################################################
# Root — Input Variables
# All values are set in dev.tfvars
# ##############################################################################

# ── General ───────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "environment" {
  description = "Environment name e.g. dev, staging, prod"
  type        = string
}

# ── EKS Cluster ───────────────────────────────────────────────────────────────
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

# ── Node Group ────────────────────────────────────────────────────────────────
variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

# ── ECR ───────────────────────────────────────────────────────────────────────
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

# ── GitHub ────────────────────────────────────────────────────────────────────
variable "github_org" {
  description = "Your GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
}

# ── Networking ────────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}