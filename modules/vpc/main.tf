# Create a VPC
resource "aws_vpc" "clbrt_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
}

# Create subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.clbrt_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    "type" = "public_subnet"
  }
}

data "aws_subnet" "us_east_1c_public" {
  availability_zone = "us-east-1c"
  tags = {
    "type" = "public_subnet"
  }
  depends_on = [
    aws_subnet.public
  ]
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.clbrt_vpc.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false
  tags = {
    "type" = "private_subnet"
  }
}

data "aws_subnet" "us_east_1c_private" {
  availability_zone = "us-east-1c"
  tags = {
    "type" = "private_subnet"
  }
  depends_on = [
    aws_subnet.private
  ]
}

data "aws_subnet" "us_east_1d_private" {
  availability_zone = "us-east-1d"
  tags = {
    "type" = "private_subnet"
  }
  depends_on = [
    aws_subnet.private
  ]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.clbrt_vpc.id
}

resource "aws_route_table" "gw" {
  vpc_id = aws_vpc.clbrt_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.gw.id
}

# Security groups

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic within VPC"
  vpc_id      = aws_vpc.clbrt_vpc.id

  ingress {
    description = "SSH within VPC"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["192.168.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
    Web  = true
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.clbrt_vpc.id

  ingress {
    description = "HTTP from public subnets"
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["192.168.0.0/27", "192.168.0.32/27"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
    Web  = true
  }
}

resource "aws_security_group" "allow_http_elb" {
  name        = "allow_http_elb"
  description = "Allow HTTP inbound Internet traffic"
  vpc_id      = aws_vpc.clbrt_vpc.id

  ingress {
    description = "HTTP from Internet subnets"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_elb"
    Elb  = true
  }
}

resource "aws_security_group" "natsg" {
  name        = "natsg"
  description = "NATSG security group"
  vpc_id      = aws_vpc.clbrt_vpc.id

  ingress {
    description = "HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["192.168.0.64/27", "192.168.0.96/27"]
  }

  ingress {
    description = "HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["192.168.0.64/27", "192.168.0.96/27"]
  }

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["192.168.0.64/27", "192.168.0.96/27"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "natsg"
    Bastion = true
  }
}

resource "aws_security_group" "allow_ssh_ww" {
  name        = "allow_ssh_ww"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.clbrt_vpc.id

  ingress {
    description = "SSH from WW"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "allow_ssh_ww"
    Bastion = true
  }
}

data "aws_security_groups" "bastion" {
  tags = {
    Bastion = true
  }

  depends_on = [
    aws_security_group.allow_ssh_ww,
    aws_security_group.natsg
  ]
}

data "aws_security_groups" "web" {
  tags = {
    Web = true
  }

  depends_on = [
    aws_security_group.allow_ssh,
    aws_security_group.allow_http
  ]
}

data "aws_security_groups" "elb" {
  tags = {
    Elb = true
  }

  depends_on = [
    aws_security_group.allow_http_elb
  ]
}
