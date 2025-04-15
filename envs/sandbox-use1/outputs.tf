output "vpc_id" {
  value = module.network.vpc.id
}

output "private_subnet_ids" {
  value = [for s in module.network.private_subnet : s.id]
}

output "public_subnet_ids" {
  value = [for s in module.network.public_subnet : s.id]
}
