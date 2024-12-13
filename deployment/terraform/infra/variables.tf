
variable "subscription_id" {
  description = "Azure subscription ID to deploy the solution."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.subscription_id) >= 1
    error_message = "Please specify a valid subscription id."
  }
}

variable "environment_name" {
  description = "Name of the the environment, used in resource group name and as tag for resources created."
  type        = string
}

variable "location" {
  description = "Primary/default location for all resources unless specified in other location parameters."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name, generated automatically if not given."
  type        = string
  default     = ""
}

variable "backend_service_code_path" {
  description = "Backend service code path."
  type        = string
  default     = "../../../backend"
}

variable "skills_service_code_path" {
  description = "Skillsets service code path."
  type        = string
  default     = "../../../custom_skills/pdf_text_image_merge_skill"
}

variable "appservice_plan_sku" {
  description = "App Service Plan Sku Name. Used for both backend and skillsets service."
  type        = string
}

variable "backend_service_name" {
  description = "Backend Service Name."
  type        = string
  default     = ""
}

variable "skills_service_name" {
  description = "Skillsets Service Name."
  type        = string
  default     = ""
}

variable "application_insights_name" {
  description = "Application Insights Name."
  type        = string
  default     = ""
}

variable "key_vault_name" {
  description = "Key vault Name."
  type        = string
  default     = ""
}

variable "key_vault_sku_name" {
  description = "Key vault SKU Name."
  type        = string
  default     = "standard"
}

variable "log_analytics_workspace_id" {
  description = "Specifies the resource ID of the log analytics workspace used for collecting logs."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.log_analytics_workspace_id)) == 9
    error_message = "Please specify a valid resource ID."
  }
}

variable "search_service_name" {
  description = "Search Service Name."
  type        = string
  default     = ""
}

variable "search_service_location" {
  description = "Search Service Location."
  type        = string
}

variable "search_service_sku" {
  description = "Search Service SKU Name."
  type        = string
  default     = "standard"
}

variable "semantic_search_sku" {
  description = "Semantic search SKU Name."
  type        = string
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
  description = "Specifies datasource name in the search service."
  type        = string
  default     = ""
}

variable "search_service_index_name" {
  description = "Specifies index name in the search service."
  type        = string
  default     = ""
}

variable "search_service_indexer_name" {
  description = "Specifies indexer name in the search service."
  type        = string
  default     = ""
}

variable "search_service_skillset_name" {
  description = "Specifies skillset name in the search service."
  type        = string
  default     = ""
}


variable "openai_service_name" {
  description = "Specifies the sku name of the Azure OpenAI service."
  type        = string
  sensitive   = false
  default     = ""
}


variable "openai_service_location" {
  description = "Azure OpenAI Service Location."
  type        = string
  validation {
    condition     = contains(["australiaeast", "canadaeast", "eastus", "eastus2", "francecentral", "japaneast", "northcentralus", "swedencentral", "switzerlandnorth", "uksouth"], var.openai_service_location)
    error_message = <<EOT
    Please specify a region that supports gpt-35-turbo,0613 models for OpenAI.
    Valid values at the time this code published are:
      - australiaeast
      - canadaeast
      - eastus
      - eastus2
      - francecentral
      - japaneast
      - northcentralus
      - swedencentral
      - switzerlandnorth
      - uksouth
    Regions that support gpt-35-turbo,0613 models are published in the page below
    https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#gpt-35-models
    EOT
  }
}

variable "openai_service_sku" {
  description = "Specifies the sku name of the Azure OpenAI service."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.openai_service_sku) >= 1
    error_message = "Please specify a valid sku name."
  }
}

variable "azure_openai_text_deployment_id" {
  description = "Azure OpenAI text deployment ID"
  type        = string
  default     = "text-embedding-ada-002"
}

variable "azure_openai_text_model_name" {
  description = "Azure OpenAI text model name"
  type        = string
  default     = "text-embedding-ada-002"
}

variable "storage_container_name_knowledgestore" {
  description = "Specifies knowledge resource contaner name."
  type        = string
  sensitive   = false
  default     = "knowledgestore"
}

variable "cognitive_service_name" {
  description = "Specifies the sku name of the cognitive service."
  type        = string
  sensitive   = false
  default     = ""
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

variable "form_recognizer_name" {
  description = "Specifies the sku name of the form recognizer service."
  type        = string
  sensitive   = false
  default     = ""
}

variable "form_recognizer_service_location" {
  description = "Form Recognizer Service Location."
  type        = string
  validation {
    condition     = contains(["eastus", "northcentralus", "westeurope", "westus2"], var.form_recognizer_service_location)
    error_message = <<EOT
    Please specify a region that supports API 2024-07-31-preview.
    Valid values at the time this code published are:
      - eastus
      - northcentralus
      - westeurope
      - westus2
    Regions that support API 2024-07-31-preview are published in the page below
    https://learn.microsoft.com/en-us/azure/cognitive-services/form-recognizer/overview#supported-apis
    EOT
  }
}

variable "form_recognizer_sku" {
  description = "Specifies the sku name of the form recognizer service."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.form_recognizer_sku) >= 1
    error_message = "Please specify a valid sku name."
  }
}

variable "computer_vision_name" {
  description = "Specifies the sku name of the computer vision service."
  type        = string
  sensitive   = false
  default     = ""
}

variable "computer_vision_service_location" {
  description = "Computer Vision Service Location."
  type        = string
  validation {
    condition     = contains(["eastus", "westus", "westus2", "francecentral", "northeurope", "westeurope", "swedencentral", "switzerlandnorth", "australiaeast", "southeastasia", "koreacentral", "japaneast"], var.computer_vision_service_location)
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


variable "computer_vision_sku" {
  description = "Specifies the sku name of the computer vision service."
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.computer_vision_sku) >= 1
    error_message = "Please specify a valid sku name."
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
  default = [
    {
      name = "gpt-4o"
      model = {
        format  = "OpenAI"
        version = "2024-05-13"
      }
      sku = {
        capacity = 20
      }
    },
    {
      name = "text-embedding-ada-002"
      model = {
        format  = "OpenAI"
        version = "2"
      }
      sku = {
        capacity = 30
      }
    },
    {
      name = "gpt-35-turbo"
      model = {
        format  = "OpenAI"
        version = "0613"
      }
      sku = {
        capacity = 60
      }
    }
  ]
}


variable "storage_account_name" {
  description = "Storage Account Name."
  type        = string
  default     = ""
}

variable "storage_container_name_content" {
  description = "Storage Container Name."
  type        = string
  default     = "docs"
}

variable "azure_openai_emb_model_name" {
  description = "OpenAI embedding model name. Must be defined in aoai_deployments parameter."
  type        = string
  default     = "text-embedding-ada-002"
}

variable "azure_openai_emb_deployment_name" {
  description = "OpenAI embedding deployment name. Must be defined in aoai_deployments parameter."
  type        = string
  default     = "text-embedding-ada-002"
}

variable "azure_openai_emb_dimensions" {
  description = "OpenAI embedding dimensions."
  type        = number
  default     = 1536
}

variable "azure_openai_chatgpt_model_name" {
  description = "OpenAI chatgpt model name. Must be defined in aoai_deployments parameter."
  type        = string
  default     = "gpt-4o"
}

variable "azure_openai_chatgpt_deployment_name" {
  description = "OpenAI chatgpt deployment name. Must be defined in aoai_deployments parameter."
  type        = string
  default     = "gpt-4o"
}

variable "azure_openai_gpt4v_model_name" {
  description = "OpenAI gpt4v model name. Must be defined in aoai_deployments parameter."
  type        = string
  default     = "gpt-4o"
}

variable "azure_openai_gpt4v_deployment_name" {
  description = "OpenAI gpt4v deployment name. Must be defined in aoai_deployments parameter."
  type        = string
  default     = "gpt-4o"
}

variable "skills_function_appregistration_client_id" {
  description = "Specifies the client id of the app registration created"
  type        = string
  sensitive   = false
  default     = ""
}

variable "webapp_auth_settings" {
  type = object({
    enable_auth           = bool
    enable_access_control = bool
    server_app = object({
      app_id           = string
      app_secret_name  = string
      app_secret_value = string
    })
    client_app = object({
      app_id           = string
      app_secret_name  = string
      app_secret_value = string
    })
  })
  default = {
    enable_auth           = true
    enable_access_control = false
    server_app = {
      app_id           = ""
      app_secret_name  = ""
      app_secret_value = ""
    }
    client_app = {
      app_id           = ""
      app_secret_name  = ""
      app_secret_value = ""
    }
  }
  sensitive = true
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

variable "subnet_cidr_web" {
  description = "Specifies the subnet cidr range for the web and function apps subnet."
  type        = string
  sensitive   = false
  validation {
    condition     = length(split("/", var.subnet_cidr_web)) == 2
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

# DNS variables
variable "private_dns_zone_id_blob" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage blob endpoints. Not required if DNS A-records get created via Azue Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_blob == "" || (length(split("/", var.private_dns_zone_id_blob)) == 9 && endswith(var.private_dns_zone_id_blob, "privatelink.blob.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_queue" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage queue endpoints. Not required if DNS A-records get created via Azue Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_queue == "" || (length(split("/", var.private_dns_zone_id_queue)) == 9 && endswith(var.private_dns_zone_id_queue, "privatelink.queue.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_table" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage table endpoints. Not required if DNS A-records get created via Azue Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_table == "" || (length(split("/", var.private_dns_zone_id_table)) == 9 && endswith(var.private_dns_zone_id_table, "privatelink.table.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
}

variable "private_dns_zone_id_file" {
  description = "Specifies the resource ID of the private DNS zone for Azure Storage file endpoints. Not required if DNS A-records get created via Azue Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_file == "" || (length(split("/", var.private_dns_zone_id_file)) == 9 && endswith(var.private_dns_zone_id_file, "privatelink.file.core.windows.net"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
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

variable "private_dns_zone_id_cognitive_services" {
  description = "Specifies the resource ID of the private DNS zone for Azure Cognitive Services. Not required if DNS A-records get created via Azure Policy."
  type        = string
  sensitive   = false
  default     = ""
  validation {
    condition     = var.private_dns_zone_id_cognitive_services == "" || (length(split("/", var.private_dns_zone_id_cognitive_services)) == 9 && endswith(var.private_dns_zone_id_cognitive_services, "privatelink.cognitiveservices.azure.com"))
    error_message = "Please specify a valid resource ID for the private DNS Zone."
  }
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
