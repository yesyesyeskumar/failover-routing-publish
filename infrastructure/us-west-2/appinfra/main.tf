

# s3 bucket
resource "aws_s3_bucket" "app_s3_bucket" {
    bucket = var.app_bucket_name
    acl    = "private"
    tags = {
        Name = "app_s3_bucket"
    }
}

resource "aws_s3_bucket_versioning" "destination" {
  bucket = aws_s3_bucket.app_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}





