provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "https://github.com/guitou4573/exercise"
    }
  }
}

terraform {
  required_version = "~> 1.1"
  backend "s3" {

  }
  required_providers {
    aws = {
      version = "~> 3.70"
    }
  }
}
