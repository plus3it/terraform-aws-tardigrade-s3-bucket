resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_request_payment_configuration" {
  source = "../../"

  bucket = random_id.name.hex

  request_payment_configuration = {
    payer = "Requester"
  }
}

output "create_request_payment_configuration" {
  value = module.create_request_payment_configuration
}
