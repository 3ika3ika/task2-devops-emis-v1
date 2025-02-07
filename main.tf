module "ec2_instance" {
  source    = "./ec2_instance"  # Path to your module
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
  ami_id    = var.ami_id
  ssh_cidr = var.ssh_cidr
  
}
