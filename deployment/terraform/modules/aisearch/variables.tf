# General variables
variable "location" {
  description = "Specifies the location of the resource group."
  type        = string
  sensitive   = false

}

variable "resource_group_name" {
  description = "Specifies the name of the resource group."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.resource_group_name) >= 2
    error_message = "Please specify a valid name."
  }
}

variable "tags" {
  description = "Specifies the tags that you want to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = {}
}

variable "search_service_name" {
  description = "Specifies the name of the search service."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.search_service_name) >= 2
    error_message = "Please specify a valid name."
  }
}

# Service variables
variable "search_service_sku" {
  description = "Specifies the SKU for the search service"
  type        = string
  sensitive   = false
  default     = "standard"
}

variable "search_service_partition_count" {
  description = "Specifies the number of partitions in the search service."
  type        = number
  sensitive   = false
  default     = 1

}

variable "search_service_replica_count" {
  description = "Specifies the number of replicas in the search service."
  type        = number
  sensitive   = false
  default     = 1

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

variable "search_service_skillset_name" {
  description = "Specifies index name."
  type        = string
  sensitive   = false
}

variable "pdf_merge_customskill_endpoint" {
  description = "Specifies endpoint for skill."
  type        = string
  sensitive   = false

}

variable "cognitive_services_endpoint" {
  description = "Azure Cognitive Services endpoint"
  type        = string
}

variable "cognitive_services_key" {
  description = "Specifies cognitive services key."
  type        = string
  sensitive   = false

}

variable "knowledgestore_storage_account_id" {
  description = "Specifies knowledge resource stroager."
  type        = string
  sensitive   = false

}

variable "knowledgestore_storage_container_name" {
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
variable "subnet_id" {
  description = "Specifies the subnet ID."
  type        = string
  sensitive   = false
  default     = ""
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
