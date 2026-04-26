# ##############################################################################
# Root — Local Values (shared across all modules)
# ##############################################################################

locals {
  common_tags = {
    Project     = "devsecops-pipeline"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "george-awa"
  }

}