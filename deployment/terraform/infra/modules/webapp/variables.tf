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

variable "webapp_name" {
  description = "Specifies the name of the data factory."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.webapp_name) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

variable "enable_auth" {
  description = "Specifies if auth is enabled for the webapp."
  type        = bool
  default     = false
}

variable "client_app_id" {
  description = "Specifies the client app registration app id."
  type        = string
  default     = ""
}

variable "server_app_id" {
  description = "Specifies the server app registration app id."
  type        = string
  default     = ""
}

variable "resource_token" {
  description = "Specifies the token appended to resource names to differentiate deployments."
  type        = string
}

variable "client_secret_setting_name" {
  description = "Specifies the name of the app setting which contains client secret."
  type        = string
  default     = ""
}



# Service variables
variable "webapp_application_settings" {
  description = "Specifies app settings this is then merged with local app settings"
  type        = map(string)
  sensitive   = false
}

variable "webapp_always_on" {
  description = "Specifies weahther always on should be enabled on the webapp."
  type        = bool
  sensitive   = false
  default     = false
}

variable "webapp_code_path" {
  description = "Specifies the code location of the webapp."
  type        = string
  sensitive   = false
}

variable "webapp_key_vault_id" {
  description = "Specifies the resource id of the key vault."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.webapp_key_vault_id)) == 9
    error_message = "Please specify a valid name."
  }
}

variable "webapp_user_assigned_identity_id" {
  description = "Specifies the resource id of the user assigned identity."
  type        = string
  sensitive   = false
  default     = null
}

variable "webapp_sku" {
  description = "Specifies the SKU for the webapp app."
  type        = string
  sensitive   = false
  validation {
    condition     = contains(["B3", "S1", "S2", "S3", "EP1", "EP2", "EP3"], var.webapp_sku)
    error_message = "Please use an allowed value: \"B1\",\"B2\",\"B3\",\"S1\",\"S2\",\"S3\",\"EP1\", \"EP2\", \"EP3\"."
  }
}


variable "webapp_build_command" {
  description = "Command to be run before deploy."
  type        = string
  sensitive   = false
}

variable "webapp_application_insights_instrumentation_key" {
  description = "Specifies the instrumentation key of application insights."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.webapp_application_insights_instrumentation_key) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

variable "webapp_application_insights_connection_string" {
  description = "Specifies the instrumentation key of application insights."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.webapp_application_insights_connection_string) >= 2
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

# Network variables
variable "subnet_id" {
  description = "Specifies the subnet name."
  type        = string
  sensitive   = false
  default     = null
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
