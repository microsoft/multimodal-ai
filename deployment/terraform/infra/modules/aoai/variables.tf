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

variable "cognitive_service_name" {
  description = "Specifies the name of the cognitive service."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.cognitive_service_name) >= 2
    error_message = "Please specify a valid name longer than 2 characters."
  }
}

# Service variables
variable "cognitive_service_kind" {
  description = "Specifies the kind of the cognitive service."
  type        = string
  sensitive   = false
  default     = "OpenAI"
  validation {
    condition     = contains(["AnomalyDetector", "ComputerVision", "CognitiveServices", "ContentModerator", "CustomVision.Training", "CustomVision.Prediction", "Face", "FormRecognizer", "ImmersiveReader", "LUIS", "Personalizer", "SpeechServices", "TextAnalytics", "TextTranslation", "OpenAI"], var.cognitive_service_kind)
    error_message = "Please specify a valid kind. Valid values are: \"AnomalyDetector\", \"ComputerVision\", \"CognitiveServices\", \"ContentModerator\", \"CustomVision.Training\", \"CustomVision.Prediction\", \"Face\", \"FormRecognizer\", \"ImmersiveReader\", \"LUIS\", \"Personalizer\", \"SpeechServices\", \"TextAnalytics\", \"TextTranslation\", \"OpenAI\"."
  }
}

variable "cognitive_service_sku" {
  description = "Specifies the sku name of the cognitive service."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.cognitive_service_sku) >= 1
    error_message = "Please specify a valid sku name."
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

variable "aoai_deployments" {
  type = list(object({
    name = string
    model = object({
      format  = string
      version = string
    })
    sku = object({
      capacity = number
    })
  }))
}

variable "local_auth_enabled" {
  description = "Specifies if the key based auth enabled."
  type        = bool
  sensitive   = false
  default     = false
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

variable "private_dns_zone_id_open_ai" {
  description = "Specifies the resource ID of the private DNS zone for Azure Open AI. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_open_ai == "" || (length(split("/", var.private_dns_zone_id_open_ai)) == 9 && endswith(var.private_dns_zone_id_open_ai, "privatelink.openai.azure.com"))
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

variable "outbound_network_access_restricted" {
  description = "Specifies the outbound network restrictions of the cognitive service."
  type        = bool
  sensitive   = false
  nullable    = false
  default     = true
}

variable "public_network_access_enabled" {
  description = "Specifies whether public network access should be enabld for the cognitive service."
  type        = bool
  sensitive   = false
  nullable    = false
  default     = false
}
