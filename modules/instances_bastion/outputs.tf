output "id" {
  value = aws_instance.nat_instance.id
}

output "public_ip" {
  value = aws_instance.nat_instance.public_ip
}
