# Fetch the existing VPC by ID
data "aws_vpc" "main" {
  id = var.existing_vpc_id  # Define `existing_vpc_id` in your variables
}

# Fetch available availability zones in the current region
data "aws_availability_zones" "available" {}

# Dynamically calculated CIDR blocks for subnets
resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = cidrsubnet(data.aws_vpc.main.cidr_block, 6, count.index) # Changed from 4 to 6
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "ken-subnet-${count.index}"
  }
}


# Internet Gateway for existing VPC (optional if it's not already created)
data "aws_internet_gateway" "existing_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
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
