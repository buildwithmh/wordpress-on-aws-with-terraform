terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "2.3.0"
    }
  }
}

provider "random" {
  # Configuration options
}

provider "aws" {
  region                  = "eu-west-3"
  shared_credentials_file = "~/.aws/cred"
  profile                 = "default"
}
