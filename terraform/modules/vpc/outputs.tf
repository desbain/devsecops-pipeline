# ##############################################################################
# VPC Module — Outputs
# These values are exported so other modules (EKS, ECR) can use them
# ##############################################################################
output "vpc_id" {
    description = "ID of the VPC — used by EKS to know which network to deploy into"
  value = aws_vpc.main.id
}

output "vpc_cidr" {
    description = "CIDR block of the VPC "
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets — used for load balancers"
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets — used for EKS worker nodes"
  value = aws_subnet.private[*].id
}