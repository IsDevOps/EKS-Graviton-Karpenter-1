# Data block for the existing VPC
data "aws_vpc" "main" {
  id = var.existing_vpc_id
}

# Data block for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Resource to create subnets
resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "my-subnet-${count.index + 1}"
  }
}

# Resource for Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = data.aws_vpc.main.id
}
