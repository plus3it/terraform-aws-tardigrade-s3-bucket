resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_intelligent_tiering" {
  source = "../../"

  bucket = random_id.name.hex

  intelligent_tiering_configuration = {
    name   = "ImportantBlueDocuments"
    status = "Enabled"

    filter = {
      prefix = "documents/"

      tags = {
        priority = "high"
        class    = "blue"
      }
    }

    tiering = [
      {
        access_tier = "DEEP_ARCHIVE_ACCESS"
        days        = 180
      },
      {
        access_tier = "ARCHIVE_ACCESS"
        days        = 125
      },
    ]
  }
}

output "create_intelligent_tiering" {
  value = module.create_intelligent_tiering
}
