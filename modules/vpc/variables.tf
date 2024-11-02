variable "existing_vpc_id" {
  type        = string
  description = "ID of the existing VPC"
  default = "vpc-007222983437ca689"

}

variable "subnet_count" {
  type        = number
  description = "Number of subnets to create"
  default     = 2
}

# Fetch the existing VPC by ID
data "aws_vpc" "main" {
  id = var.existing_vpc_id
}