variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "subnet_count" {
  description = "Number of subnets to create"
}
variable "existing_vpc_id"{
  description = "Existing VPC"
  default = "vpc-007222983437ca689"
}