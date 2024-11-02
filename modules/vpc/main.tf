# Fetch the existing VPC by ID
data "aws_vpc" "main" {
  id = var.existing_vpc_id  # Make sure to define `existing_vpc_id` in your variables
}

# Create subnets from the existing VPC CIDR
resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)  # Example: create /20 subnets
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "ken-subnet-${count.index}"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = "ken-igw"
  }
}

# Create a route table
resource "aws_route_table" "main" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "ken-route-table"
  }
}

# Associate the route table with subnets
resource "aws_route_table_association" "main" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}
