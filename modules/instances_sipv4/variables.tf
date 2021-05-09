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

variable "eth_index" {
  type    = number
  default = 0
}

variable "network_interface_id" {
  description = "ID of the network interface to attach"
  type        = string
  default     = ""
}