# ##############################################################################
# Security Groups Module — Input Variables
# ##############################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster — used to name security groups"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC — security groups must be created inside the VPC"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}