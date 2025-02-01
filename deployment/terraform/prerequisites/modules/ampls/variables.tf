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
}

variable "ampls_query_access_mode" {
  description = "Specifies the query access mode for the Azure Monitor Private Link Scope."
  type        = string
  sensitive   = false
  default     = "PrivateOnly"
}