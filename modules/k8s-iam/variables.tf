variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "tags" {
  type        = map(string)
  description = "Tags added to all created roles"
  default     = {}
}

variable "allowed_secret_names" {
  type        = list(string)
  description = "List of allowed Secrets Manager secret names"
  default     = []
}

variable "allowed_parameter_names" {
  type        = list(string)
  description = "List of allowed SSM parameter names"
  default     = []
}
