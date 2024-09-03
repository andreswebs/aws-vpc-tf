module "network" {
  source                    = "../../modules/network"
  network_name              = var.network_name
  network_cidr_ipv4         = var.network_cidr_ipv4
  private_subnet_cidrs_ipv4 = var.private_subnet_cidrs_ipv4
  public_subnet_cidrs_ipv4  = var.public_subnet_cidrs_ipv4
}
