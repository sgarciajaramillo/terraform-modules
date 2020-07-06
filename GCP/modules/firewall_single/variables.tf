# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "vpcs" {
  type        = list(string)
  description = "VPC Networks"
}

variable "fw_ingress" {
  type        = list(string)
  description = "Firewall Ingress"
  # default     = ["public-fw-ingress", "private-fw-ingress"]
}

variable "fw_egress" {
  type        = list(string)
  description = "Firewall Egress"
  # default     = ["public-fw-egress", "private-fw-egress"]
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "random_string" {
  type        = string
  default     = "abc"
  description = "Random String"
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
