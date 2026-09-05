# General variables
variable "location" {
  description = "Specifies the location of the search service."
  type        = string
  sensitive   = false
  validation {
    condition     = contains(["eastus", "westus", "westus2", "francecentral", "northeurope", "westeurope", "swedencentral", "switzerlandnorth", "australiaeast", "southeastasia", "koreacentral", "japaneast"], var.location)
    error_message = <<EOT
    Please specify a region for search service that supports Multimodal embeddings
    Valid values at the time this code published are:
      - eastus
      - westus
      - westus2
      - francecentral
      - northeurope
      - westeurope
      - swedencentral
      - switzerlandnorth
      - australiaeast
      - southeastasia
      - koreacentral
      - japaneast
    Regions that support multimodal embeddings are published here
    https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/overview-image-analysis?tabs=4-0#region-availability
    EOT
  }
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

variable "search_service_name" {
  description = "Specifies the name of the search service precreated to save time."
  type        = string
  sensitive   = false
}

variable "search_service_identity" {
  description = "Specifies the system managed identity principalid of the search service account precrated to save time."
  type        = string
  sensitive   = false
}

variable "search_service_resource_id" {
  description = "Specifies the resource id for the search service precrated to save time."
  type        = string
  sensitive   = false
}

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

variable "cognitive_account_id" {
  description = "Specifies the id for the cognitive account."
  type        = string
  sensitive   = false
}

variable "function_id" {
  description = "Specifies the id for the function app."
  type        = string
  sensitive   = false
}

variable "form_recognizer_id" {
  description = "Specifies the id for the form recognizer account."
  type        = string
  sensitive   = false
}

variable "vision_id" {
  description = "Specifies the id for the vision account."
  type        = string
  sensitive   = false
}

variable "search_service_datasource_name" {
  description = "Specifies datasource name."
  type        = string
  sensitive   = false
}

variable "search_service_index_name" {
  description = "Specifies index name."
  type        = string
  sensitive   = false
}

variable "search_service_indexer_name" {
  description = "Specifies index name."
  type        = string
  sensitive   = false
}

variable "openai_account_id" {
  description = "Specifies the id for the AOAI account."
  type        = string
  sensitive   = false
}

variable "search_service_skillset_name" {
  description = "Specifies index name."
  type        = string
  sensitive   = false
}

variable "function_app_id" {
  description = ""
  type        = string
  sensitive   = false
}

variable "pdf_merge_customskill_endpoint" {
  description = "Specifies endpoint for skill."
  type        = string
  sensitive   = false

}

variable "computer_vision_endpoint" {
  description = ""
  type        = string
}

variable "cognitive_services_endpoint" {
  description = "Azure Cognitive Services endpoint"
  type        = string
}

variable "knowledgestore_storage_account_id" {
  description = "Specifies knowledge resource stroager."
  type        = string
  sensitive   = false

}

variable "storage_container_name_knowledgestore" {
  description = "Specifies knowledge resource contaner name."
  type        = string
  sensitive   = false

}

variable "azure_openai_endpoint" {
  description = "Azure OpenAI endpoint"
  type        = string
}

variable "azure_openai_text_deployment_id" {
  description = "Azure OpenAI text deployment ID"
  type        = string
}

variable "azure_openai_text_model_name" {
  description = "Azure OpenAI text model name"
  type        = string
}

variable "storage_account_id" {
  description = "Storage account id"
  type        = string
  sensitive   = false
}

variable "storage_container_name_content" {
  description = "Storage container name"
  type        = string
  sensitive   = false
  default     = "content"
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
  default     = ""
}

variable "private_dns_zone_id_ai_search" {
  description = "Specifies the resource ID of the private DNS zone for Azure AI Search. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_ai_search == "" || (length(split("/", var.private_dns_zone_id_ai_search)) == 9 && endswith(var.private_dns_zone_id_ai_search, "privatelink.search.windows.net"))
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

variable "public_network_access_enabled" {
  description = "Specifies whether public network access should be enabld for the cognitive service."
  type        = bool
  sensitive   = false
  nullable    = false
  default     = false
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
