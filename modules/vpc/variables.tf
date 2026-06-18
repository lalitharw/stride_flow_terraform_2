variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for vpc"
}


variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "redis_subnet" {
  type = string
}
