variable "alb-sg-id" {
  type = string
}

variable "public_subnets_id" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "instance" {
  type = list(string)
}