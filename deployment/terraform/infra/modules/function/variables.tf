# General variables
variable "subscription_id" {
  description = "subscription_id"
  type        = string
  sensitive   = false
  default     = ""
}

variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.resource_group_name) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
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

variable "function_name" {
  description = "Specifies the name of the data factory."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.function_name) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

# Service variables
variable "function_application_settings" {
  description = "Specifies app settings this is then merged with local app settings"
  type        = map(string)
  sensitive   = false
}

variable "function_always_on" {
  description = "Specifies weahther always on should be enabled on the function."
  type        = bool
  sensitive   = false
  default     = false
}

variable "function_code_path" {
  description = "Specifies the code location of the function."
  type        = string
  sensitive   = false
}

variable "function_storage_account_id" {
  description = "Specifies the resource id of the storage account."
  type        = string
  sensitive   = false
  default     = null
  validation {
    condition     = length(split("/", var.function_storage_account_id)) == 9
    error_message = "Please specify a valid name."
  }
}

variable "function_key_vault_id" {
  description = "Specifies the resource id of the key vault."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.function_key_vault_id)) == 9
    error_message = "Please specify a valid name."
  }
}

variable "function_user_assigned_identity_id" {
  description = "Specifies the resource id of the user assigned identity."
  type        = string
  sensitive   = false
  default     = null
}

variable "function_sku" {
  description = "Specifies the SKU for the function app."
  type        = string
  sensitive   = false
}

variable "function_application_insights_instrumentation_key" {
  description = "Specifies the instrumentation key of application insights."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.function_application_insights_instrumentation_key) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

variable "function_application_insights_connection_string" {
  description = "Specifies the instrumentation key of application insights."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.function_application_insights_connection_string) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
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

variable "skills_function_appregistration_client_id" {
  description = "Specifies the client id of the app registration created"
  type        = string
  sensitive   = false
}

# Network variables
variable "subnet_id" {
  description = "Specifies the subnet id."
  type        = string
  sensitive   = false
  default     = null
}

variable "private_dns_zone_id_sites" {
  description = "Specifies the resource ID of the private DNS zone for Azure Websites. Not required if DNS A-records get created via Azue Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_sites == "" || (length(split("/", var.private_dns_zone_id_sites)) == 9 && endswith(var.private_dns_zone_id_sites, "privatelink.azurewebsites.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}


# Customer-managed key variables
variable "customer_managed_key" {
  description = "Specifies the customer managed key configurations."
  type = object({
    key_vault_id                     = string,
    key_vault_key_versionless_id     = string,
    user_assigned_identity_id        = string,
    user_assigned_identity_client_id = string,
  })
  sensitive = false
  nullable  = true
  default   = null
  validation {
    condition = alltrue([
      var.customer_managed_key == null || length(split("/", try(var.customer_managed_key.key_vault_id, ""))) == 9,
      var.customer_managed_key == null || startswith(try(var.customer_managed_key.key_vault_key_versionless_id, ""), "https://"),
      var.customer_managed_key == null || length(split("/", try(var.customer_managed_key.user_assigned_identity_id, ""))) == 9,
      var.customer_managed_key == null || length(try(var.customer_managed_key.user_assigned_identity_client_id, "")) >= 2,
    ])
    error_message = "Please specify a valid resource ID."
  }
}
