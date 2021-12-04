terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.37"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }
    auth0 = {
      source = "alexkappa/auth0"
      version = "~> 0.20"
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

provider "auth0" {
  domain = var.auth0_canonical_domain
  client_id = var.auth0_tf_client_id
  client_secret = var.auth0_tf_client_secret
  debug = "true"
}
