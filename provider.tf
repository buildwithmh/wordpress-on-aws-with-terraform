terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "2.3.0"
    }
  }
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/cred"
  profile                 = "sandbox"
}

provider "random" {
  # Configuration options
}


