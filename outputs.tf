output "public_subnet_ids" {
  value = [for s in module.vpc.subnets_public : s.id]
}

output "private_subnet_ids" {
  value = [for s in module.vpc.subnets_private : s.id]
}

output "bastion_public_ip" {
  value = module.bastion-host.public_ip
}