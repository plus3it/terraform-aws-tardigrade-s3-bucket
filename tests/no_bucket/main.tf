provider "aws" {
  region = "us-east-1"
}

module "no_bucket" {
  source = "../../"
  providers = {
    aws = aws
  }

  create_bucket = false
  bucket        = null

}

output "no_bucket" {
  value = module.no_bucket
}
