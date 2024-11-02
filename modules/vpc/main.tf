# Variables for existing VPC ID, CIDR, and subnet count


# Fetch the existing VPC by ID
data "aws_vpc" "main" {
  id = var.existing_vpc_id
}

# Fetch the existing Internet Gateway associated with the VPC
data "aws_internet_gateway" "main" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Create subnets within the existing VPC
resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = cidrsubnet(data.aws_vpc.main.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "ken-subnet-${count.index}"
  }
}

# Create a route table associated with the existing VPC
resource "aws_route_table" "main" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.main.id
  }

  tags = {
    Name = "ken-route-table"
  }
}

# Associate the route table with each subnet
resource "aws_route_table_association" "main" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}

# Outputs for VPC, subnet, and gateway information if needed
output "vpc_id" {
  value = data.aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.main[*].id
}

output "internet_gateway_id" {
  value = data.aws_internet_gateway.main.id
}
