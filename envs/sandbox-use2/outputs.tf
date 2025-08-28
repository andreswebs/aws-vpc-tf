output "vpc_id" {
  value = module.network.vpc.id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "sg_id" {
  value = module.web_alb.sg.id
}
