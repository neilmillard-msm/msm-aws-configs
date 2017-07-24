provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

variable "aws_region" {
    description = "AWS region to use"
    type = "string"
}
variable "aws_access_key" {
    description = "AWS Access Key to use"
    type = "string"
}
variable "aws_secret_key" {
    description = "AWS Secret Access Key to use"
    type = "string"
}

variable "account" {
  description = "Naming Convention: The account name"
  type = "string"
  default = "msm"
}

variable "user_base" {
  description = "Naming Convention: The code for the user base"
  type = "string"
  default = "gb"
}

variable "environment" {
  description = "Naming Convention: The short name for the environment"
  type = "string"
  default = "env"
}

variable "service_group" {
  description = "Naming Convention: The name for the service group or s3 bucket name suffix"
  type = "string"
}

variable "objects_prefix" {
  description = "Naming Convention: objects path prefix for lifecycle management"
  type = "string"
}
