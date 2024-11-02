
# Use the existing VPC's ID to create subnets
resource "aws_subnet" "main" {
  count                   = var.subnet_count
  vpc_id                  = data.aws_vpc.main.id
  cidr_block              = "10.0.${count.index * 16}.0/20"  # or use one of the recommended blocks
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "my-subnet-${count.index + 1}"
  }
}


# Fetch the existing Internet Gateway attached to the VPC
data "aws_internet_gateway" "existing_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Route table associated with the VPC
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

# Associate the route table with each subnet
resource "aws_route_table_association" "main" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}

# Outputs for VPC, subnet, and gateway information if needed

output "igw_id" {
  value = data.aws_internet_gateway.existing_igw.id
}
