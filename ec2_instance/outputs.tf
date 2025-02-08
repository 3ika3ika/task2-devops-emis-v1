output "private_key_pem" {
  value     = tls_private_key.generated_key.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "ec2_id" {
  value = aws_instance.ec2_instance.id
}