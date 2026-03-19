output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.main.id
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.main.id
}

output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.main.private_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.main.id
}

output "environment" {
  description = "Deployed environment"
  value       = var.environment
}
