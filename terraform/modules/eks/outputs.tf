# ##############################################################################
# EKS Module — Outputs
# These values are used by root outputs.tf and kubectl configuration
# ##############################################################################

# ── Cluster ───────────────────────────────────────────────────────────────────
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

# ── Authentication ────────────────────────────────────────────────────────────
output "cluster_certificate_authority" {
  description = "Base64 encoded certificate authority data — used by kubectl to verify the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

# ── Node Group ────────────────────────────────────────────────────────────────
output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.app_nodes.status
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.app_nodes.arn
}