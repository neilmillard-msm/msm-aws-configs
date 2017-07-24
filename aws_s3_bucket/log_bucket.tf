resource "aws_s3_bucket" "log_bucket" {
  bucket = "aws01-s3-logging"
  acl    = "log-delivery-write"

  lifecycle_rule {
    id      = "log"
    prefix  = "log/"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}
