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

variable "storage_account_name" {
  description = "Specifies the name of the storage account."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.storage_account_name) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

# Service variables
variable "storage_account_container_names" {
  description = "Specifies the container names of the storage account."
  type        = list(string)
  sensitive   = false
  default     = []
  validation {
    condition = alltrue([
      length([for storage_account_container_name in var.storage_account_container_names : storage_account_container_name if length(storage_account_container_name) < 2]) <= 0
    ])
    error_message = "Please specify a valid name."
  }
}

variable "storage_account_share_names" {
  description = "Specifies the share names of the storage account."
  type        = list(string)
  sensitive   = false
  default     = []
  validation {
    condition = alltrue([
      length([for storage_account_share_name in var.storage_account_share_names : storage_account_share_name if length(storage_account_share_name) < 2]) <= 0
    ])
    error_message = "Please specify a valid name."
  }
}

variable "storage_account_shared_access_key_enabled" {
  description = "Specifies the key auth setting of the storage account."
  type        = bool
  sensitive   = false
  default     = false
}

variable "storage_account_hns_enabled" {
  description = "Specifies the hns setting of the storage account."
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

# Network variables
variable "public_network_access_enabled" {
  description = "Specifies whether public network access should be enabld for the storage account."
  type        = bool
  sensitive   = false
  nullable    = false
  default     = false
}

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

variable "private_endpoint_subresource_names" {
  description = "Specifies a list of group ids for which private endpoints will be created (e.g. 'blob', 'file', etc.). If sub resource is defined a private endpoint will be created."
  type        = set(string)
  sensitive   = false
  nullable    = false
  default     = ["blob", "file"]
  validation {
    condition = alltrue([
      length([for private_endpoint_subresource_name in var.private_endpoint_subresource_names : private_endpoint_subresource_name if !contains(["blob", "file", "queue", "table", "dfs", "web"], private_endpoint_subresource_name)]) <= 0
    ])
    error_message = "Please specify a valid group id."
  }
}

variable "private_dns_zone_id_blob" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage blob endpoints. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_blob == "" || (length(split("/", var.private_dns_zone_id_blob)) == 9 && endswith(var.private_dns_zone_id_blob, "privatelink.blob.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_file" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage file endpoints. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_file == "" || (length(split("/", var.private_dns_zone_id_file)) == 9 && endswith(var.private_dns_zone_id_file, "privatelink.file.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_table" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage table endpoints. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_table == "" || (length(split("/", var.private_dns_zone_id_table)) == 9 && endswith(var.private_dns_zone_id_table, "privatelink.table.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_queue" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage queue endpoints. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_queue == "" || (length(split("/", var.private_dns_zone_id_queue)) == 9 && endswith(var.private_dns_zone_id_queue, "privatelink.queue.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_web" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage web endpoints. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_web == "" || (length(split("/", var.private_dns_zone_id_web)) == 9 && endswith(var.private_dns_zone_id_web, "privatelink.web.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_dfs" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage dfs endpoints. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_dfs == "" || (length(split("/", var.private_dns_zone_id_dfs)) == 9 && endswith(var.private_dns_zone_id_dfs, "privatelink.dfs.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
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

variable "network_bypass" {
  description = "Specifies bypass options for the storage account network rules. List can include \"None\", \"AzureServices\", \"Metrics\" and \"Logs\""
  type        = set(string)
  sensitive   = false
  nullable    = false
  default     = ["None"]
  validation {
    condition = alltrue([
      length([for value in toset(var.network_bypass) : value if !contains(["None", "AzureServices", "Metrics", "Logs"], value)]) <= 0
    ])
    error_message = "Please provide a valid list. Valid values: \"None\", \"AzureServices\", \"Metrics\" and \"Logs\"."
  }
}

variable "default_action" {
  description = "Specifies the default firewall rule of the storage account."
  type        = string
  sensitive   = false
  nullable    = false
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.default_action)
    error_message = "Please specify a valid default action. Allowed values are: [ 'Allow', 'Deny' ]"
  }
}

variable "network_private_link_access" {
  description = "Specifies resource instance rules of the storage account."
  type        = set(string)
  sensitive   = false
  nullable    = false
  default     = []
  validation {
    condition = alltrue([
      length([for value in toset(var.network_private_link_access) : value if length(split("/", value)) < 7]) <= 0
    ])
    error_message = "Please provide a valid resource id that has the following format: \"/subscriptions/.../resourceGroups/.../providers/.../.../...\" or \"/subscriptions/.../providers/.../.../...\"."
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
