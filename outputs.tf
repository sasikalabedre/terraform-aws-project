output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "app_instance_id" {
  description = "ID of the app server"
  value       = aws_instance.app.id
}

output "app_url" {
  description = "Web address of the app"
  value       = "http://${aws_instance.app.public_ip}"
}