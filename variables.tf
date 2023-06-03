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

#
#// This variable holds the
#// number of public and private subnets
#variable "subnet_count" {
#  description = "Number of subnets"
#  type        = map(number)
#  default = {
#    public  = 1,
#    private = 2
#  }
#}
#
#// This variable contains the configuration
#// settings for the EC2 and RDS instances
#variable "settings" {
#  description = "Configuration settings"
#  type        = map(any)
#  default = {
#    "database" = {
#      allocated_storage   = 10            // storage in gigabytes
#      engine              = "mysql"       // engine type
#      engine_version      = "8.0.27"      // engine version
#      instance_class      = "db.t2.micro" // rds instance type
#      db_name             = "tutorial"    // database name
#      skip_final_snapshot = true
#    },
#    "web_app" = {
#      count         = 1          // the number of EC2 instances
#      instance_type = "t2.micro" // the EC2 instance
#    }
#  }
#}
#
#// This variable contains the CIDR blocks for
#// the public subnet. I have only included 4
#// for this tutorial, but if you need more you
#// would add them here
#variable "public_subnet_cidr_blocks" {
#  description = "Available CIDR blocks for public subnets"
#  type        = list(string)
#  default = [
#    "10.0.1.0/24",
#    "10.0.2.0/24",
#    "10.0.3.0/24",
#    "10.0.4.0/24"
#  ]
#}
#
#// This variable contains the CIDR blocks for
#// the public subnet. I have only included 4
#// for this tutorial, but if you need more you
#// would add them here
#variable "private_subnet_cidr_blocks" {
#  description = "Available CIDR blocks for private subnets"
#  type        = list(string)
#  default = [
#    "10.0.101.0/24",
#    "10.0.102.0/24",
#    "10.0.103.0/24",
#    "10.0.104.0/24",
#  ]
#}
