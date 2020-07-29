# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "random_string" {
  type        = string
  default     = "abc"
  description = "Random String"
}

variable "public_vpc_network" {
  type        = string
  default     = "public_vpc_network"
  description = "Public VPC Network"
}

variable "private_vpc_network" {
  type        = string
  default     = "private_vpc_network"
  description = "Private VPC Network"
}

variable "sync_vpc_network" {
  type        = string
  default     = "sync_vpc_network"
  description = "Sync VPC Network"
}

variable "mgmt_vpc_network" {
  type        = string
  default     = "mgmt_vpc_network"
  description = "Management VPC Network"
}

variable "source_ranges" {
  type        = list
  default     = ["0.0.0.0/0"]
  description = "Source Range"
}

variable "destination_ranges" {
  type        = list
  default     = ["0.0.0.0/0"]
  description = "Destination Range"
}

variable "allow_all" {
  type        = string
  default     = "all"
  description = "Default Allow Protocol"
}