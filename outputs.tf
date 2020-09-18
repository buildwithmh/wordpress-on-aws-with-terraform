output "ec2_public_ip" {
  value       = aws_instance.wordpress.public_ip
  description = "EC2 WordPress public ipv4 address"
}
