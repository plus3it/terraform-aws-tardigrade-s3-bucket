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
  region        = null

}
