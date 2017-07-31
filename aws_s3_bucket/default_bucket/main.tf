variable "account" {}
variable "user_base" {}
variable "environment" {}
variable "service_group" {}
variable "objects_prefix" {}
variable "log_bucket" {}

resource "aws_s3_bucket" "default_bucket" {
  bucket = "${var.account}-${var.user_base}-${var.environment}-${var.service_group}"
  acl    = "private"

  force_destroy = true

  logging {
    target_bucket = "${var.log_bucket}"
    target_prefix = "log/"
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "default_lifecycle"
    prefix  = "${var.objects_prefix}"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

  }

  tags {
    ACCOUNT       = "${var.account}"
    USER_BASE     = "${var.user_base}"
    ENVIRONMENT   = "${var.environment}"
    SERVICE_GROUP = "${var.service_group}"
  }
}
