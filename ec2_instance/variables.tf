# variables.tf
variable "vpc_id" {
  description = "ID of the VPC where the EC2 instance will be launched"
  type        = string
  
}

variable "subnet_id" {
  description = "ID of the subnet where the EC2 instance will be launched"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "name" {
  type        = string
  default = "terraform-user"
}

variable "key_name" {
  type        = string
  default = "key-for-ssh"
}

variable "ssh_cidr" {
  type        = list(string)
  default = ["0.0.0.0/0"]
}

variable "iam_instance_profile_name" {
  type = string
}