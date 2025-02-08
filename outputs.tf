output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
}

output "ec2_private_key" {
  value = module.ec2_instance.private_key_pem
  sensitive=true
}

output "s3_file" {
  value = module.s3_buckets.image_url
}
