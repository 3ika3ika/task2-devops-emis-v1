variable "vpc_id" {
  description = "The VPC ID where the EC2 instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID where the EC2 instance will be deployed"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "ssh_cidr" {
  description = "The CIDR block allowed to SSH into the EC2 instances"
  type        = list(string)
  default = ["0.0.0.0/0"]
}

variable "endpoint_email" {
  description = "The email you want to recieve CloudWatch Alarm notifications"
  type = string
}

variable "bucket_name" {
  description = "The name of your bucket must be unique across all AWS buckets globally"
  type = string
}