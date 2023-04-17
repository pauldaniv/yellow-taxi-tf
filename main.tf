provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us-east-2"
  region = "us-east-2"
}

data "aws_availability_zones" "available" {}


resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_kms_key" "codeartifact" {
  provider                = aws.us-east-2
  deletion_window_in_days = 7 #set to as small as possible
  enable_key_rotation     = true
  tags                    = merge({ "Name" = "codeartifact" }, var.tags)
}
