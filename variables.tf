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


// This variable holds the
// number of public and private subnets
variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 1,
    private = 2
  }
}

// This variable contains the configuration
// settings for the EC2 and RDS instances
variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage   = 10            // storage in gigabytes
      engine              = "mysql"       // engine type
      engine_version      = "8.0.27"      // engine version
      instance_class      = "db.t2.micro" // rds instance type
      db_name             = "tutorial"    // database name
      skip_final_snapshot = true
    },
    "web_app" = {
      count         = 1          // the number of EC2 instances
      instance_type = "t2.micro" // the EC2 instance
    }
  }
}

// This variable contains the CIDR blocks for
// the public subnet. I have only included 4
// for this tutorial, but if you need more you
// would add them here
#variable "public_subnet_cidr_blocks" {
#  description = "Available CIDR blocks for public subnets"
#  type        = list(string)
#  default = [
#    "10.0.140.0/24",
#    "10.0.141.0/24",
#    "10.0.142.0/24",
#    "10.0.143.0/24"
#  ]
#}

// This variable contains the CIDR blocks for
// the public subnet. I have only included 4
// for this tutorial, but if you need more you
// would add them here
#variable "private_subnet_cidr_blocks" {
#  description = "Available CIDR blocks for private subnets"
#  type        = list(string)
#  default = [
#    "10.0.160.0/24",
#    "10.0.161.0/24",
#    "10.0.162.0/24",
#    "10.0.163.0/24",
#  ]
#}
