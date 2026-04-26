# ##############################################################################
# Root — Outputs
# Printed after terraform apply completes
# ##############################################################################

# ── VPC ───────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

# ── EKS ───────────────────────────────────────────────────────────────────────
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = module.eks.cluster_version
}

output "cluster_certificate_authority" {
  description = "Certificate authority data for kubectl"
  value       = module.eks.cluster_certificate_authority
  sensitive   = true
}

# ── ECR ───────────────────────────────────────────────────────────────────────
output "repository_url" {
  description = "Full URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

# ── IAM ───────────────────────────────────────────────────────────────────────
output "pipeline_role_arn" {
  description = "ARN of the GitHub Actions pipeline role"
  value       = module.iam.pipeline_role_arn
}

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.iam.cluster_role_arn
}

# ── kubectl Config Command ────────────────────────────────────────────────────
output "kubectl_config_command" {
  description = "Run this command after apply to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}