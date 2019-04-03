variable "project" {}

variable "stage" {}

variable "vpc_id" {}

# variable "workers_security_group_ids" {
#     type        = "list"
#     description = "Security Group IDs of the worker nodes"
# }

variable "additional_security_groups" {
  type        = "list"
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the EKS cluster"
}

variable "additional_cidr_blocks" {
  type        = "list"
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster"
}

variable "k8s_version" {
  type        = "string"
  default     = "1.12"
  description = "Kubernetes version"
}

variable "subnet_ids" {
  description = "List of subnet IDs to for the EKS Cluster"
  type        = "list"
}

variable "enable_private_access" {}
variable "enable_public_access" {}
