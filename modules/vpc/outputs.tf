output "id" {
  value = aws_vpc.clbrt_vpc.id
}

output "subnets_public" {
  value = aws_subnet.public
}

output "subnets_private" {
  value = aws_subnet.private
}

output "us_east_1c_subnet_private" {
  value = data.aws_subnet.us_east_1c_private
}

output "us_east_1d_subnet_private" {
  value = data.aws_subnet.us_east_1d_private
}

output "us_east_1c_subnet_public" {
  value = data.aws_subnet.us_east_1c_public
}

output "security_groups_ids_bastion" {
  value = data.aws_security_groups.bastion.ids
}

output "security_groups_ids_web" {
  value = data.aws_security_groups.web.ids
}

output "security_groups_ids_elb" {
  value = data.aws_security_groups.elb.ids
}