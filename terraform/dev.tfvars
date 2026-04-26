# ##############################################################################
# Dev Environment — Variable Values
# These are the actual values used when running:
# terraform apply -var-file="dev.tfvars"
# ##############################################################################

# ── General ───────────────────────────────────────────────────────────────────
aws_region  = "us-east-2"
environment = "dev"

# ── EKS Cluster ───────────────────────────────────────────────────────────────
cluster_name    = "devsecops-cluster"
cluster_version = "1.34"

# ── Node Group ────────────────────────────────────────────────────────────────
node_instance_type = "t3.medium"
node_min_size      = 2
node_max_size      = 4
node_desired_size  = 2

# ── ECR ───────────────────────────────────────────────────────────────────────
repository_name = "devsecops-app"

# ── GitHub ────────────────────────────────────────────────────────────────────
github_org  = "desbain"
github_repo = "devsecops-pipeline"

# ── Networking ────────────────────────────────────────────────────────────────
vpc_cidr = "10.0.0.0/16"