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
    # no dynamodb_table = ... so no locking
  }
}

variable "aws_access_key" {
    type        = string
    sensitive   = true
}
variable "aws_secret_key" {
    type        = string
    sensitive   = true
}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#
# Secondary provider required as all certificates must be in us east 1
#
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
    hosted_zone_name  = "heritools.com"   # root zone in Route53
    domain_name       = "iiif.heritools.com"
}

#
# Bucket to store the source files
# TODO
#  - Standard IA class to be moved to deeper archival class after
#    x amount of time
#
resource "aws_s3_bucket" "hert_iif_source_bucket" {
  bucket = "hert-iif-source"
  tags = {
    Name        = "Hert Source"
    Environment = "Dev"
  }
}

#
# Bucket to store the generated tiles
#
resource "aws_s3_bucket" "hert_iif_dist_bucket" {
  bucket = "hert-iiif-dist"

  tags = {
    Name        = "Hert Distribution"
    Environment = "Dev"
  }
}

#
# Create a cert for the custom domains
#
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = local.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "HeriTools.com Certificate"
  }
}


# Look up the hosted zone in Route 53
data "aws_route53_zone" "this" {
  name         = "${local.hosted_zone_name}."
  private_zone = false
}

# DNS records for ACM validation (handles 1 or many domains)
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# Tell ACM to validate using those DNS records
resource "aws_acm_certificate_validation" "cert" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}