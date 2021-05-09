variable "cidr_block" {
  description = "A cidr_block of VPC"
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "A list of cidr_block for public subnets"
  type        = list(string)
  default     = ["192.168.0.0/27", "192.168.0.32/27"]
}

variable "private_subnets" {
  description = "A list of cidr_blocks for private subnets"
  type        = list(string)
  default     = ["192.168.0.64/27", "192.168.0.96/27"]
}

variable "azs" {
  description = "A list of availability zones"
  type        = list(string)
  default     = []
}
