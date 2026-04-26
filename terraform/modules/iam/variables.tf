variable "cluster_name" {
  description = "Name of the EKS cluster - use to tag subnets"
  type        = string
}

# ---------Tags-------------------------------------------------------------------------
variable "tags" {
  description = "Map of strings to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "github_org" {
  description = "Your GitHub username or organization"
  type        = string
}

variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
}