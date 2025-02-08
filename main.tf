module "iam" {
    source = "./iam_roles"
}
module "ec2_instance" {
  source    = "./ec2_instance"  
  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
  ami_id    = var.ami_id
  ssh_cidr = var.ssh_cidr
  iam_instance_profile_name = module.iam.ec2_instance_profile
}

module "s3_buckets" {
  source    = "./s3_buckets"
}