terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Store state remotely — replace with your bucket name
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "devsecops-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ── ECR Repository ────────────────────────────────────────────────────────
resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true  # Auto-scan every pushed image
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

# ECR lifecycle policy — keep only last 10 images
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

# ── EKS Cluster ───────────────────────────────────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Enable private endpoint — no public API server exposure
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true  # Set false after initial setup

  # Enable secrets encryption at rest
  cluster_encryption_config = {
    resources = ["secrets"]
  }

  eks_managed_node_groups = {
    app_nodes = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 5
      desired_size   = 2

      # Use latest EKS-optimized AMI
      use_latest_ami_release_version = true

      labels = {
        Environment = var.environment
        Project     = "devsecops"
      }
    }
  }

  # Enable CloudWatch logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = local.common_tags
}

# ── VPC ───────────────────────────────────────────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.eks_cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true  # Set false for production HA

  # Required tags for EKS ALB controller
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.common_tags
}

# ── Locals ────────────────────────────────────────────────────────────────
locals {
  common_tags = {
    Project     = "devsecops-pipeline"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "george-awa"
  }
}
