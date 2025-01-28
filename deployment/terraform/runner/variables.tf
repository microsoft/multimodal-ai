# General variables
variable "location" {
  description = "Specifies the location for all Azure resources."
  type        = string
  sensitive   = false
}

variable "environment" {
  description = "Specifies the environment of the deployment."
  type        = string
  sensitive   = false
  default     = "dev"
  validation {
    condition     = contains(["int", "dev", "tst", "qa", "uat", "prd"], var.environment)
    error_message = "Please use an allowed value: \"int\", \"dev\", \"tst\", \"qa\", \"uat\" or \"prd\"."
  }
}

variable "prefix" {
  description = "Specifies the prefix for all resources created in this deployment."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.prefix) >= 2 && length(var.prefix) <= 10
    error_message = "Please specify a prefix with more than two and less than 10 characters."
  }
}

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

# Github variables
variable "github_org_name" {
  description = "Specifies the name of the GitHub org."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.github_org_name) > 2
    error_message = "Please specify a valid name."
  }
}

variable "github_personal_access_token" {
  description = "Specifies the personal access token for the GitHub org."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.github_personal_access_token) > 2
    error_message = "Please specify a valid PAT token."
  }
}

# Container variables
variable "container_image_reference" {
  description = "Specifies the container image reference used in Azure Container Jobs."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.container_image_reference) > 2
    error_message = "Please specify a valid container reference."
  }
}

# Logging variables
variable "log_analytics_workspace_id" {
  description = "Specifies the resource ID of the log analytics workspace used for collecting logs."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.log_analytics_workspace_id)) == 9
    error_message = "Please specify a valid resource ID."
  }
}

# Network variables
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

variable "vnet_id" {
  description = "Specifies the resource ID of the Vnet used for the Azure Function."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.vnet_id)) == 9
    error_message = "Please specify a valid resource ID."
  }
}

variable "nsg_id" {
  description = "Specifies the resource ID of the default network security group for the Azure Function."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.nsg_id)) == 9
    error_message = "Please specify a valid resource ID."
  }
}

variable "route_table_id" {
  description = "Specifies the resource ID of the default route table for the Azure Function."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.route_table_id)) == 9
    error_message = "Please specify a valid resource ID."
  }
}

variable "subnet_cidr_container_app" {
  description = "Specifies the subnet cidr range for teh container app subnet."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.subnet_cidr_container_app)) == 2
    error_message = "Please specify a valid subnet cidr range."
  }
}

variable "subnet_cidr_private_endpoints" {
  description = "Specifies the subnet cidr range for private endpoints."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.subnet_cidr_private_endpoints)) == 2
    error_message = "Please specify a valid subnet cidr range."
  }
}

variable "private_dns_zone_id_vault" {
  description = "Specifies the resource ID of the private DNS zone for Azure Key Vault. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_vault == "" || (length(split("/", var.private_dns_zone_id_vault)) == 9 && endswith(var.private_dns_zone_id_vault, "privatelink.vaultcore.azure.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}
