variable "subnets" {
  description = "A list of public subnets"
  type        = list(any)
  default     = []
}

variable "security_groups" {
  description = "A list of security_groups"
  type        = list(string)
  default     = []
}