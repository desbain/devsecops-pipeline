# ##############################################################################
# IAM Module — Outputs
# These values are passed to the EKS module
# ##############################################################################

# ── Cluster Role ──────────────────────────────────────────────────────────────
output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role — passed to EKS cluster resource"
  value       = aws_iam_role.eks_cluster.arn
}

output "cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.name
}

# ── Node Role ─────────────────────────────────────────────────────────────────
output "nodes_role_arn" {
  description = "ARN of the EKS nodes IAM role — passed to EKS node group resource"
  value       = aws_iam_role.eks_nodes.arn
}

output "nodes_role_name" {
  description = "Name of the EKS nodes IAM role"
  value       = aws_iam_role.eks_nodes.name
}

output "pipeline_role_arn" {
  description = "ARN of the GitHub Actions pipeline role — passed to ECR module"
  value       = aws_iam_role.pipeline.arn
}