provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket       = "saibucket876"
    key          = "terraform/terraform.tfstate"
    use_lockfile = true
    region       = "us-east-1"
  }
}
