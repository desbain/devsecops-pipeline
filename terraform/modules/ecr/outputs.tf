# ##############################################################################
# ECR Module — Outputs
# ##############################################################################

output "repository_url" {
  description = "Full URL of the ECR repository — used by pipeline to push images"
  value       = aws_ecr_repository.app.repository_url
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app.name
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.app.arn
}

output "registry_id" {
  description = "AWS account ID associated with the registry"
  value       = aws_ecr_repository.app.registry_id
}