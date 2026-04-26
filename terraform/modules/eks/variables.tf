# ##############################################################################
# EKS Module — Input Variables
# ##############################################################################

# ── Cluster ───────────────────────────────────────────────────────────────────
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

# ── IAM — received from IAM module outputs ────────────────────────────────────
variable "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role — from module.iam.eks_cluster_role_arn"
  type        = string
}

variable "nodes_role_arn" {
  description = "ARN of the EKS nodes IAM role — from module.iam.eks_nodes_role_arn"
  type        = string
}

# ── Networking — received from VPC module outputs ─────────────────────────────
variable "vpc_id" {
  description = "ID of the VPC — from module.vpc.vpc_id"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs — from module.vpc.private_subnet_ids"
  type        = list(string)
}

# ── Security — received from security_groups module outputs ───────────────────
variable "cluster_sg_id" {
  description = "Security group ID for EKS control plane — from module.security_groups.eks_cluster_sg_id"
  type        = string
}

# ── Node Group ────────────────────────────────────────────────────────────────
variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

# ── Tags ──────────────────────────────────────────────────────────────────────
variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}