# Fetch the existing VPC by ID
data "aws_vpc" "main" {
  id = var.existing_vpc_id  # Make sure to define `existing_vpc_id` in your variables
}

# Use the existing VPC's ID to create subnets
resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = cidrsubnet(data.aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "ken-subnet-${count.index}"
  }
}

# Internet Gateway for existing VPC (optional if it's not already created)
# Only create it if needed, otherwise, fetch an existing one
data "aws_internet_gateway" "existing_igw" {
  vpc_id = data.aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing_igw.id
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
