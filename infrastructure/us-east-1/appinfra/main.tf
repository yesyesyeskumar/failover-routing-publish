terraform {
#   required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.11.0"
      configuration_aliases = [ aws.dr ]
    }
  }

}

provider "aws" {
  alias = "dr"
  region = "us-west-2"
}



data "aws_s3_bucket" "app_s3_bucket" {
    provider = aws.dr
    bucket = var.destination_bucket_name
}


# s3 bucket
# enable cross region replication

resource "aws_s3_bucket" "app_s3_bucket" {
    bucket = var.app_bucket_name
    acl    = "private"
    tags = {
        Name = "app_s3_bucket"
    }
}


resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.app_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [aws_s3_bucket_versioning.source]
  role   = var.replication_role_arn
  bucket = aws_s3_bucket.app_s3_bucket.id

  rule {
    id = "1234"

    status = "Enabled"

    destination {
      bucket        = data.aws_s3_bucket.app_s3_bucket.arn
      storage_class = "STANDARD"
    }
  }
}







