terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.29"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }
    auth0 = {
      source = "alexkappa/auth0"
      version = "~> 0.19"
    }
  }

  backend "remote" {
    organization = "opalpolicy"
    workspaces {
      name = "accounts-infra"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.region
}

