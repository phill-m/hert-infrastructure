terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.6.0"
    }
  }
  backend "s3" {
    bucket  = "hert-terraform-state"
    key     = "dev/iiif/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
    # no dynamodb_table = ... → no locking
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#
# Bucket to store the source files
# TODO
#  - Standard IA class to be moved to deeper archival class after
#    x amount of time
#
resource "aws_s3_bucket" "hert-iif-source-bucket" {
  bucket = "hert-iif-source"
  tags = {
    Name        = "Hert Source"
    Environment = "Dev"
  }
}

#
# Bucket to store the generated tiles
#
resource "aws_s3_bucket" "hert-iif-dist-bucket" {
  bucket = "hert-iiif-dist"

  tags = {
    Name        = "NWG OWM"
    Environment = "Dev"
  }
}