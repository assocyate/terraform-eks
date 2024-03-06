terraform {
  backend "s3" {
    key    = "github-actions-cicd/terraform.tfstate" # the directory/file.tfstate
    bucket = "tfstate-gitlab"             # the bucket
    region = "us-west-2"             # the region
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "kubectl" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster.id]
    command     = "aws"
  }
}

variable "region" {
  default = "us-west-2"
}

variable "cluster_name" {
  default = "demo2"
}

variable "namespace" {
  default = "explore-california"
}

variable "release_name" {
  default = "explore-california-website"
}

variable "cluster_version" {
  default = "1.29"
}

variable "scale" {
  default = "autoscale"
  #default = "karpenter"
  #default = "none"
}

variable "prometheus" {
  #default = "yes"
  default = "no"
}