output "role" {
  description = "Map of IAM roles"
  value       = local.role
}

output "role_arns" {
  description = "Map of IAM role ARNs"
  value       = { for role_name, role in local.role : role_name => role.arn }
}
