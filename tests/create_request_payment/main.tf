resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_bucket" {
  source = "../../"

  bucket = random_id.name.hex

  request_payment_configuration = {
    expected_bucket_owner = null
    payer                 = "Requester"
  }
}

output "create_bucket" {
  value = module.create_bucket
}
