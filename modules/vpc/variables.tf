
variable "existing_vpc_id" {
  type        = string
  description = "ID of the existing VPC"
  default = "vpc-007222983437ca689"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the existing VPC"
  default  =  "10.0.0.0/16"
}

variable "subnet_count" {
  type        = number
  description = "Number of subnets to create"
  default     = 2
}