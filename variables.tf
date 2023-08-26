variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "tags" {
  description = "Tags used across all infrastructure resources"
  type        = map(string)
  default     = {"goal": "promotion", "project": "yellow-taxi"}
}

variable "db_public_access" {
  type    = bool
  default = true
}

variable "db_subnets" {
  type    = list(string)
  default = [
    "10.0.140.0/24",
    "10.0.141.0/24",
    "10.0.142.0/24",
    "10.0.143.0/24"
  ]
}

