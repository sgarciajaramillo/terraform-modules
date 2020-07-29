# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "random_string" {
  default     = "abc"
  description = "Random String"
}

variable "static_ip" {
  type        = string
  default     = "static_ip"
  description = "Static IP"
}
