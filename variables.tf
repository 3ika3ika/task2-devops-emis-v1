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
