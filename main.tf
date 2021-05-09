module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.cidr_block
  azs        = var.azs
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCf7evCLga4Pm0Xqsd+qSAtGjQVyrl4Eb2O8VH+Ht+XU7Ek8CrmwIHMuIi7++7XkNxWzUwwB3h0E2slnXodNEQwRd4km/Tk4SWezBv3oayBD0Y3VYZxjA5B7Nfq9DicTaWGQ8YeKVG49ezXypY+urbs9xfaTnLKMKtBLT1ZAGpHhZxtcQY19jMdvEn4Q57EEY6edQEp9nMsGdBDJ9ZzLSq1N3iDXaJw3yKcQVDOzZIQhoBEosXb+GxjeJVprW9DosXRbdaLcM/hwxi8e8Fm+AUCF5YTOfBzu4R94ANi8oWafwbQYqGxsh2mdhPfujDUabuL+FTnw/NU+J+92+3F2biP"
}

module "elb" {
  source          = "./modules/load_balancer"
  subnets         = module.vpc.subnets_public
  security_groups = module.vpc.security_groups_ids_elb
}

module "bastion-host" {
  source                 = "./modules/instances_bastion"
  subnet_id              = module.vpc.us_east_1c_subnet_public.id
  az                     = "us-east-1c"
  key_name               = aws_key_pair.deployer.key_name
  vpc_id                 = module.vpc.id
  vpc_security_group_ids = module.vpc.security_groups_ids_bastion
}

# Web-host 1
resource "aws_network_interface" "web1_eth0" {
  subnet_id       = module.vpc.us_east_1c_subnet_private.id
  private_ips     = ["192.168.0.94"]
  security_groups = module.vpc.security_groups_ids_web
}

module "web-host-1" {
  source               = "./modules/instances_sipv4"
  az                   = "us-east-1c"
  key_name             = aws_key_pair.deployer.key_name
  network_interface_id = aws_network_interface.web1_eth0.id
}

resource "aws_elb_attachment" "w1" {
  elb      = module.elb.id
  instance = module.web-host-1.id
}

# Web-host 2
resource "aws_network_interface" "web2_eth0" {
  subnet_id       = module.vpc.us_east_1d_subnet_private.id
  private_ips     = ["192.168.0.126"]
  security_groups = module.vpc.security_groups_ids_web
}

module "web-host-2" {
  source               = "./modules/instances_sipv4"
  az                   = "us-east-1d"
  key_name             = aws_key_pair.deployer.key_name
  network_interface_id = aws_network_interface.web2_eth0.id
}

resource "aws_elb_attachment" "w2" {
  elb      = module.elb.id
  instance = module.web-host-2.id
}
