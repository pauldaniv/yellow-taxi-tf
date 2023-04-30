resource "aws_kms_key" "codeartifact" {
  provider                = var.region
  deletion_window_in_days = 7 #set to as small as possible
  enable_key_rotation     = true
  tags                    = merge({ "Name" = "codeartifact" }, var.tags)
}
