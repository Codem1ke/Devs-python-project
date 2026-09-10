# Display the public IP after creation
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.devops_server.public_ip
}

# Display the public DNS name
output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.devops_server.public_dns
}
