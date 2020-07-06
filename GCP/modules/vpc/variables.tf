# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "vpcs" {
  type        = list(string)
  description = "Create(s) VPC with the labels"
  # default   = ["public-vpc", "private-vpc", "sync_network", "mgmt_network"]
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "random_string" {
  default     = "abc"
  description = "Random String"
}
