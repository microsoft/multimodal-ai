# General variables
variable "location" {
  description = "Specifies the location for all Azure resources."
  type        = string
  sensitive   = false
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

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

variable "key_vault_name" {
  description = "Specifies the name of the key vault."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.key_vault_name) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

# Service variables
variable "key_vault_sku_name" {
  description = "Select the SKU for the Key Vault"
  type        = string
  sensitive   = false
}

variable "key_vault_keys" {
  description = "Specifies the key vault keys that should be deployed."
  type = map(object({
    # curve    = optional(string, "P-256")
    key_size = optional(number, 2048)
    key_type = optional(string, "RSA")
  }))
  sensitive = false
  nullable  = false
  default   = {}
  validation {
    condition = alltrue([
      # length([for curve in values(var.key_vault_keys)[*].curve : curve if !contains(["P-256", "P-256K", "P-384", "P-521"], curve)]) <= 0,
      length([for key_type in values(var.key_vault_keys)[*].key_type : key_type if !contains(["EC", "EC-HSM", "RSA", "RSA-HSM"], key_type)]) <= 0,
    ])
    error_message = "Please specify a valid key spec."
  }
}


variable "key_vault_secrets" {
  description = "Specifies the key vault secrets that should be deployed."
  type = list(object({
    secret_name  = string
    secret_value = string
  }))
  sensitive = false
  nullable  = false
  default   = []
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
variable "vnet_location" {
  description = "The location of the VNET to create the private endpoint in the same location."
  type        = string
}

variable "subnet_id" {
  description = "Specifies the subnet ID."
  type        = string
  sensitive   = false
  default     = null
}

variable "public_network_access_enabled" {
  description = "Specifies whether public network access should be enabld for the cognitive service."
  type        = bool
  sensitive   = false
  nullable    = false
  default     = false
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

variable "private_dns_zone_id_key_vault" {
  description = "Specifies the resource ID of the private DNS zone for Azure Key Vault. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_key_vault == "" || (length(split("/", var.private_dns_zone_id_key_vault)) == 9 && endswith(var.private_dns_zone_id_key_vault, "privatelink.vaultcore.azure.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}
