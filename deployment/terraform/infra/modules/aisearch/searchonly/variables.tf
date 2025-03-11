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
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

variable "search_service_sku" {
  description = "Specifies the SKU for the search service"
  type        = string
  sensitive   = false
  default     = "standard"
}

variable "semantic_search_sku" {
  description = "Specifies the SKU for the semantic search"
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