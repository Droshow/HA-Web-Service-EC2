terraform {
  required_providers {
    aws = {
      version = "= 4.10.0"
      source  = "hashicorp/aws"
    }
  }

  required_version = ">= 1.0"

}
#provide your own creds
provider "aws" {
  region  = "eu-central-1"
  profile = "SolutionArchitect"

}
