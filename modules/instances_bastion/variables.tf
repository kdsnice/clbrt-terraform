variable "subnet_id" {
  description = "Subnet id"
  type        = string
  default     = ""
}

variable "az" {
  description = "Availability zone"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH Public key name"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = []
}