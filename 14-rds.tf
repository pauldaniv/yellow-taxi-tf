data "aws_availability_zones" "available" {
  state = "available"
}
// Create an internet gateway named "tutorial_igw"
// and attach it to the "tutorial_vpc" VPC



// Create a group of public subnets based on the variable subnet_count.public
resource "aws_subnet" "tutorial_public_subnet" {
  // count is the number of resources we want to create
  // here we are referencing the subnet_count.public variable which
  // current assigned to 1 so only 1 public subnet will be created
  count = var.subnet_count.public

  // Put the subnet into the "tutorial_vpc" VPC
  vpc_id = module.vpc.vpc_id

  // We are grabbing a CIDR block from the "public_subnet_cidr_blocks" variable
  // since it is a list, we need to grab the element based on count,
  // since count is 1, we will be grabbing the first cidr block
  // which is going to be 10.0.1.0/24
  cidr_block = var.public_subnet_cidr_blocks[count.index]

  // We are grabbing the availability zone from the data object we created earlier
  // Since this is a list, we are grabbing the name of the element based on count,
  // so since count is 1, and our region is us-east-2, this should grab us-east-2a
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // We are tagging the subnet with a name of "tutorial_public_subnet_" and
  // suffixed with the count
  tags = {
    Name = "tutorial_public_subnet_${count.index}"
  }
}

// Create a group of private subnets based on the variable subnet_count.private
resource "aws_subnet" "tutorial_private_subnet" {
  // count is the number of resources we want to create
  // here we are referencing the subnet_count.private variable which
  // current assigned to 2, so 2 private subnets will be created
  count = var.subnet_count.private

  // Put the subnet into the "tutorial_vpc" VPC
  vpc_id = module.vpc.vpc_id

  // We are grabbing a CIDR block from the "private_subnet_cidr_blocks" variable
  // since it is a list, we need to grab the element based on count,
  // since count is 2, the first subnet will grab the CIDR block 10.0.101.0/24
  // and the second subnet will grab the CIDR block 10.0.102.0/24
  cidr_block = var.private_subnet_cidr_blocks[count.index]

  // We are grabbing the availability zone from the data object we created earlier
  // Since this is a list, we are grabbing the name of the element based on count,
  // since count is 2, and our region is us-east-2, the first subnet should
  // grab us-east-2a and the second will grab us-east-2b
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // We are tagging the subnet with a name of "tutorial_private_subnet_" and
  // suffixed with the count
  tags = {
    Name = "tutorial_private_subnet_${count.index}"
  }
}


// Create a public route table named "tutorial_public_rt"
#resource "aws_route_table" "tutorial_public_rt" {
#  // Put the route table in the "tutorial_vpc" VPC
#  vpc_id = module.vpc.vpc_id
#
#  // Since this is the public route table, it will need
#  // access to the internet. So we are adding a route with
#  // a destination of 0.0.0.0/0 and targeting the Internet
#  // Gateway "tutorial_igw"
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.tutorial_igw.id
#  }
#}

// Here we are going to add the public subnets to the
// "tutorial_public_rt" route table
#resource "aws_route_table_association" "public" {
#  // count is the number of subnets we want to associate with
#  // this route table. We are using the subnet_count.public variable
#  // which is currently 1, so we will be adding the 1 public subnet
#  count = var.subnet_count.public
#
#  // Here we are making sure that the route table is
#  // "tutorial_public_rt" from above
#  route_table_id = aws_route_table.tutorial_public_rt.id
#
#  // This is the subnet ID. Since the "tutorial_public_subnet" is a
#  // list of the public subnets, we need to use count to grab the
#  // subnet element and then grab the id of that subnet
#  subnet_id = aws_subnet.tutorial_public_subnet[count.index].id
#}

// Create a private route table named "tutorial_private_rt"
resource "aws_route_table" "tutorial_private_rt" {
  // Put the route table in the "tutorial_VPC" VPC
  vpc_id = module.vpc.vpc_id

  // Since this is going to be a private route table,
  // we will not be adding a route
}

// Here we are going to add the private subnets to the
// route table "tutorial_private_rt"
resource "aws_route_table_association" "private" {
  // count is the number of subnets we want to associate with
  // the route table. We are using the subnet_count.private variable
  // which is currently 2, so we will be adding the 2 private subnets
  count = var.subnet_count.private

  // Here we are making sure that the route table is
  // "tutorial_private_rt" from above
  route_table_id = aws_route_table.tutorial_private_rt.id

  // This is the subnet ID. Since the "tutorial_private_subnet" is a
  // list of private subnets, we need to use count to grab the
  // subnet element and then grab the ID of that subnet
  subnet_id = aws_subnet.tutorial_private_subnet[count.index].id
}

// Create a security for the EC2 instances called "tutorial_web_sg"
#resource "aws_security_group" "public_security_group" {
#  // Basic details like the name and description of the SG
#  name        = "tutorial_web_sg"
#  description = "Security group for tutorial web servers"
#  // We want the SG to be in the "tutorial_vpc" VPC
#  vpc_id      = module.vpc.vpc_id
#
#  ingress {
#    from_port   = "5432"
#    to_port     = "5432"
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  // This outbound rule is allowing all outbound traffic
#  // with the EC2 instances
#  egress {
#    description = "Allow all outbound traffic"
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  // Here we are tagging the SG with the name "tutorial_web_sg"
#  tags = {
#    Name = "yt-db-sg"
#  }
#}

// Create a security group for the RDS instances called "tutorial_db_sg"
resource "aws_security_group" "db_sg" {
  // Basic details like the name and description of the SG
  name        = "tutorial_db_sg"
  description = "Security group for tutorial databases"
  // We want the SG to be in the "tutorial_vpc" VPC
  vpc_id      = module.vpc.vpc_id

  // The third requirement was "RDS should be on a private subnet and
  // inaccessible via the internet." To accomplish that, we will
  // not add any inbound or outbound rules for outside traffic.

  // The fourth and finally requirement was "Only the EC2 instances
  // should be able to communicate with RDS." So we will create an
  // inbound rule that allows traffic from the EC2 security group
  // through TCP port 3306, which is the port that MySQL
  // communicates through
  ingress {
    description     = "Allow Postgres traffic from only the web sg"
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  ingress {
    from_port   = "5432"
    to_port     = "5432"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  // Here we are tagging the SG with the name "tutorial_db_sg"
  tags = {
    Name = "yellow-taxi-db-sg"
  }
}
#
#resource "aws_security_group_rule" "inbound_rule" {
#  from_port                = 5432
#  protocol                 = "tcp"
#  security_group_id        = aws_security_group.private_db_sg.id
#  to_port                  = 5432
#  type                     = "ingress"
#  source_security_group_id = module.eks.cluster_security_group_id
#}

#// Create a db subnet group named "tutorial_db_subnet_group"
resource "aws_db_subnet_group" "db_subnet_group" {
  // The name and description of the db subnet group
  name        = "db_subnet_group"
  description = "DB subnet group for db"

  // Since the db subnet group requires 2 or more subnets, we are going to
  // loop through our private subnets in "tutorial_private_subnet" and
  // add them to this db subnet group
  subnet_ids = [for subnet in aws_subnet.tutorial_private_subnet : subnet.id]
}


data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod_yt_db_pass"
}


resource "aws_db_instance" "postgres" {
  db_name           = "service"
  username          = "service"
  password          = data.aws_secretsmanager_secret_version.db.secret_string
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible    = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

output "db_instance_url" {
  value = aws_db_instance.postgres.endpoint
}
