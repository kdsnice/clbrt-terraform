variable "cidr_block" {
  description = "A cidr_block of VPC"
  type        = string
  default     = "192.168.0.0/24"
}

variable "azs" {
  description = "A list of availability zones"
  type        = list(string)
  default     = ["us-east-1c", "us-east-1d"]
}
