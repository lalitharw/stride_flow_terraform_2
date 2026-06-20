variable "backend_sg_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "redis_sg_id" {
  type = string
}


variable "redis_private_subnet" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}