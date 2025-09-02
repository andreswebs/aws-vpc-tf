module "network" {
  source     = "andreswebs/vpc/aws"
  version    = "0.0.4"
  name       = var.network_name
  cidr_block = var.network_cidr_ipv4

  private_subnet_cidr_blocks = var.private_subnet_cidrs_ipv4
  public_subnet_cidr_blocks  = var.public_subnet_cidrs_ipv4

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
}
