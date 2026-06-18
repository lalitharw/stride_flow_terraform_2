variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block"
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
