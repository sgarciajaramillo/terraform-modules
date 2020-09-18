# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "Region"
}

variable "vpc_network" {
  type        = string
  description = "VPC Network"
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
