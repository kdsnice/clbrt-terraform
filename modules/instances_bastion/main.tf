resource "aws_instance" "nat_instance" {
  ami                         = "ami-01ef31f9f39c5aaed" # Amazon Linux AMI 2018.03.0.20200716.0 x86_64 VPC HVM ebs
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  source_dest_check           = false
  availability_zone           = var.az
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids
}

resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat_instance.id
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = var.vpc_id
  route_table_id = aws_route_table.main.id
}
