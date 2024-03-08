terraform {
  backend "s3" {
    key    = "github-actions-cicd/terraform-dns.tfstate" # the directory/file.tfstate
    bucket = "tfstate-gitlab"             # the bucket
    region = "us-west-2"             # the region
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Create variables
variable "lb_arn" {
  type    = string
  default = ""
}

# get the name of LB
variable "lb_name" {
  type    = string
  default = ""
}

variable "lb_tg_arn" {
  type    = string
  default = ""
}

# get the name of Target Group
variable "lb_tg_name" {
  type    = string
  default = ""
}

# Provide existing registered domain name
variable "public_dns_name" {
  default = "assocyate.net"
}

# Provide the hostname
variable "dns_hostname" {
  default = "go"
}
