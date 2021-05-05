provider "aws" {
  region = "us-east-1"
}

resource "random_id" "name" {
  byte_length = 6
  prefix      = "tardigrade-s3-bucket-"
}

module "create_bucket" {
  source = "../../"
  providers = {
    aws = aws
  }

  bucket = random_id.name.hex

  notifications = {
    lambda_functions = [
      {
        lambda_function_arn = module.lambda.function_arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = null
        filter_suffix       = null
      }
    ]
    topics = [
      {
        topic_arn     = aws_sns_topic_policy.this.arn
        events        = ["s3:ObjectRemoved:*"]
        filter_prefix = null
        filter_suffix = null
      }
    ]
    queues = [
      {
        queue_arn     = aws_sqs_queue.this.arn
        events        = ["s3:ObjectRestore:*"]
        filter_prefix = null
        filter_suffix = null
      }
    ]
  }

  tags = {
    environment = "testing"
  }

  depends_on = [
    aws_sqs_queue_policy.this,
    aws_lambda_permission.this,
  ]
}

module "lambda" {
  source = "git::https://github.com/plus3it/terraform-aws-lambda.git?ref=v1.3.0"

  function_name = random_id.name.hex
  handler       = "lambda.handler"
  runtime       = "python3.8"
  source_path   = "${path.module}/lambda.py"
}

resource "aws_lambda_permission" "this" {
  action         = "lambda:InvokeFunction"
  function_name  = module.lambda.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = "arn:${data.aws_partition.current.partition}:s3:::${random_id.name.hex}"
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_sns_topic" "this" {}

resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn
  policy = templatefile("templates/sns_policy.json", {
    account_id  = data.aws_caller_identity.current.account_id
    bucket_name = random_id.name.hex
    partition   = data.aws_partition.current.partition
    topic_arn   = aws_sns_topic.this.arn
  })
}

resource "aws_sqs_queue" "this" {}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id

  policy = templatefile("templates/sqs_policy.json", {
    account_id  = data.aws_caller_identity.current.account_id
    bucket_name = random_id.name.hex
    partition   = data.aws_partition.current.partition
    queue_arn   = aws_sqs_queue.this.arn
  })
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

output "create_bucket" {
  value = module.create_bucket
}
