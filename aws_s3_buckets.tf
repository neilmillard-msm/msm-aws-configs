resource "aws_s3_bucket" "log_bucket" {
  bucket = "msm-gb-any-buckets-log"
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

module "aws_s3_bucket-msm_gb_any_bucket1" {
  source = "./aws_s3_bucket/default_bucket"
  account = "msm"
  user_base = "gb"
  environment = "any"
  service_group = "bucket1"
  objects_prefix = "objects/"
  log_bucket = "${aws_s3_bucket.log_bucket.id}"
}

module "aws_s3_bucket-msm_gb_any_bucket2" {
  source = "./aws_s3_bucket/default_bucket"
  account = "${var.account}"
  user_base = "${var.user_base}"
  environment = "${var.environment}"
  service_group = "bucket2"
  objects_prefix = "objects/"
  log_bucket = "${aws_s3_bucket.log_bucket.id}"
}
