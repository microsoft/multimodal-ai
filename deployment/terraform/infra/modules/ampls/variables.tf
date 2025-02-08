# General variables
variable "location" {
  description = "Specifies the location for the resource group and the Azure Monitor Private Link Scope."
  type        = string
  sensitive   = false
}

variable "resource_group_name" {
  description = "Specifies the name of the resource group for the Azure Monitor Private Link Scope."
  type        = string
  sensitive   = false
}

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

# Service variables
variable "ampls_name" {
  description = "Specifies the name of the Azure Monitor Private Link Scope."
  type        = string
  sensitive   = false
}

variable "ampls_ingestion_access_mode" {
  description = "Specifies the ingestion access mode for the Azure Monitor Private Link Scope."
  type        = string
  sensitive   = false
  default     = "PrivateOnly"
  validation {
    condition     = contains(["PrivateOnly", "Open"], var.ampls_ingestion_access_mode)
    error_message = "The ingestion access mode must be either 'PrivateOnly' or 'Open'."
  }
}

variable "ampls_query_access_mode" {
  description = "Specifies the query access mode for the Azure Monitor Private Link Scope."
  type        = string
  sensitive   = false
  default     = "PrivateOnly"
  validation {
    condition     = contains(["PrivateOnly", "Open"], var.ampls_query_access_mode)
    error_message = "The query access mode must be either 'PrivateOnly' or 'Open'."
  }
}

# Network variables
variable "vnet_location" {
  description = "The location of the VNET to create the private endpoint in the same location."
  type        = string
}

variable "subnet_id" {
  description = "Specifies the subnet ID."
  type        = string
  sensitive   = false
  default     = ""
}

variable "connectivity_delay_in_seconds" {
  description = "Specifies the delay in seconds after the private endpoint deployment (required for the DNS automation via Policies)."
  type        = number
  sensitive   = false
  nullable    = false
  default     = 120
  validation {
    condition     = var.connectivity_delay_in_seconds >= 0
    error_message = "Please specify a valid non-negative number."
  }
}

variable "private_dns_zone_list_ampls" {
  description = "Specifies the resource ID of the private DNS zones for Azure Monitor Private Link Scope. Not required if DNS A-records get created via Azure Policy."
  type        = list(string)
  sensitive   = false
  default     = []
}
