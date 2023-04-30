variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags used across all infrastructure resources"
  type        = map(string)
  default     = {"goal": "promotion", "project": "yellow-taxi"}
}
