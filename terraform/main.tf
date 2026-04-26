# ##############################################################################
# Root — Main Configuration
# Wires all modules together in the correct order
# ##############################################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state stored in S3
  backend "s3" {
    bucket         = "devsecops-terraform-state-905418310734"
    key            = "devsecops-pipeline/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

# ── Provider ──────────────────────────────────────────────────────────────────
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# ── Module 1: VPC ─────────────────────────────────────────────────────────────
# Runs first — everything else depends on the VPC
module "vpc" {
  source = "./modules/vpc"

  aws_region   = var.aws_region
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  environment  = var.environment
  tags         = local.common_tags
}

# ── Module 2: Security Groups ─────────────────────────────────────────────────
# Runs second — needs vpc_id from VPC module
module "security_groups" {
  source = "./modules/security_groups"

  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  tags         = local.common_tags
}

# ── Module 3: IAM ─────────────────────────────────────────────────────────────
# Runs third — independent of VPC and security groups
module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster_name
  github_org   = var.github_org
  github_repo  = var.github_repo
  tags         = local.common_tags
}

# ── Module 4: EKS ─────────────────────────────────────────────────────────────
# Runs fourth — needs VPC, security groups, and IAM outputs
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_sg_id      = module.security_groups.eks_cluster_sg_id
  cluster_role_arn   = module.iam.cluster_role_arn
  nodes_role_arn     = module.iam.nodes_role_arn
  node_instance_type = var.node_instance_type
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size
  node_desired_size  = var.node_desired_size
  tags               = local.common_tags
}

# ── Module 5: ECR ─────────────────────────────────────────────────────────────
# Runs fifth — needs IAM outputs
module "ecr" {
  source = "./modules/ecr"

  repository_name   = var.repository_name
  nodes_role_arn    = module.iam.nodes_role_arn
  pipeline_role_arn = module.iam.pipeline_role_arn
  tags              = local.common_tags
}