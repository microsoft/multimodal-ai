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

# Service variables
variable "ampls_scoped_service_name" {
  description = "Specifies the name of the Azure Monitor Private Link Scoped Service."
  type        = string
  sensitive   = false
}

variable "ampls_scope_name" {
  description = "Specifies the name of the Azure Monitor Private Link Scope."
  type        = string
  sensitive   = false
}

variable "azure_monitor_resource_id" {
  description = "Specifies the Azure Monitor resource ID."
  type        = string
  sensitive   = false
}