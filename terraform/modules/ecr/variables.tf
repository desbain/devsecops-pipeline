# ##############################################################################
# ECR Module — Input Variables
# ##############################################################################

# ── Repository ────────────────────────────────────────────────────────────────
variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

# ── IAM — received from IAM module outputs ────────────────────────────────────
variable "nodes_role_arn" {
  description = "ARN of the EKS nodes IAM role — allows nodes to pull images from ECR"
  type        = string
}

variable "pipeline_role_arn" {
  description = "ARN of the GitHub Actions IAM role — allows pipeline to push images to ECR"
  type        = string
}

# ── Tags ──────────────────────────────────────────────────────────────────────
variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}