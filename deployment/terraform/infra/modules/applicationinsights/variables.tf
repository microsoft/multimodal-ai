# General variables
variable "location" {
  description = "Specifies the location for the resource group and the log analytics workspace"
  type        = string
  sensitive   = false
}

variable "resource_group_name" {
  description = "Specifies the name of the resource group for the log analytics workspace"
  type        = string
  sensitive   = false
}

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

variable "application_insights_name" {
  description = "Specifies the name of the log app insights component"
  type        = string
  sensitive   = false
}

variable "app_insights_internet_ingestion_enabled" {
  description = "Specifies if internet ingestion is enabled for the app insights component"
  type        = bool
  sensitive   = false
  default     = false
}

variable "app_insights_internet_query_enabled" {
  description = "Specifies if internet query is enabled for the app insights component"
  type        = bool
  sensitive   = false
  default     = false
}

variable "app_insights_local_authentication_disabled" {
  description = "Specifies if local authentication is disabled for the app insights component"
  type        = bool
  sensitive   = false
  default     = true
}

# Monitoring variables
variable "log_analytics_workspace_id" {
  description = "Specifies the resource ID of the log analytics workspace used for the stamp"
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.log_analytics_workspace_id)) == 9
    error_message = "Please specify a valid resource ID."
  }
}
