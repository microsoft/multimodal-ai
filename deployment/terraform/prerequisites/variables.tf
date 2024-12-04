# General variables
variable "location" {
  description = "Specifies the location for all Azure resources."
  type        = string
  sensitive   = false
}

variable "environment_name" {
  description = "Name of the the environment, used in resource group name and as tag for resources created."
  type        = string
}

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

# Service variables
variable "virtual_network_address_space" {
  description = "Specifies the data residency requirements of the bot framework."
  type        = string
  sensitive   = false
  nullable    = false
  default     = "10.0.0.0/20"
  validation {
    condition     = length(split("/", var.virtual_network_address_space)) == 2
    error_message = "Please specify a valid vnet cidr range."
  }
}
