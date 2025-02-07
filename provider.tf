terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1.0"
      
    }
  }
}

provider "aws" {
  alias  = "us_west_3"
  region = "us-west-3"
}