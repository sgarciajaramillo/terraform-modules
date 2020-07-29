# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "target_instance_id" {
  type        = string
  description = "Target Instance ID"
}

variable "static_ip" {
  type        = string
  description = "External IP"
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
