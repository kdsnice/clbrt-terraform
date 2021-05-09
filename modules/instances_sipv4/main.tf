resource "aws_instance" "ec2instance_sipv4" {
  ami               = "ami-0747bdcabd34c712a" # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type
  instance_type     = "t2.micro"
  availability_zone = var.az
  key_name          = var.key_name
  user_data         = <<-EOF
    #! /bin/bash
    apt-get update
    sudo apt-get install -y docker.io python3-pip
    pip3 install docker
    usermod -a -G docker ubuntu
  EOF

  network_interface {
    network_interface_id = var.network_interface_id
    device_index         = var.eth_index
  }
}

