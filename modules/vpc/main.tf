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
  cidr_block              = cidrsubnet(data.aws_vpc.main.cidr_block, 4, count.index)  # Ensure this doesn't overlap
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "my-subnet-${count.index}"
  }
}

# Internet Gateway for existing VPC (optional if it's not already created)
resource "aws_internet_gateway" "my_igw" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = "my-internet-gateway"
  }
}


resource "aws_route_table" "main" {
  vpc_id = data.aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"  # This allows all internet traffic
    gateway_id = aws_internet_gateway.my_igw.id  # Reference the new IGW
  }

  tags = {
    Name = "main-route-table"
  }
}


# Associate the route table with subnets
resource "aws_route_table_association" "main" {
  count          = var.subnet_count  # Assuming you are creating multiple subnets
  subnet_id      = aws_subnet.main[count.index].id  # Adjust as per your subnet resource
  route_table_id = aws_route_table.main.id
}
