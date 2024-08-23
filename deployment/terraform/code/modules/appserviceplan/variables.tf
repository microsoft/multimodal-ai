# General variables
variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.resource_group_name) >= 2
    error_message = "Please specify a valid name."
  }
}

variable "location" {
  description = "Specifies the location of the resource group."
  type        = string
  sensitive   = false
}

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

variable "appservice_name" {
  description = "Specifies the name of the data factory."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.appservice_name) >= 2
    error_message = "Please specify a valid name."
  }
}
variable "appservice_sku" {
  description = "Specifies the SKU for the resource."
  type        = string
}