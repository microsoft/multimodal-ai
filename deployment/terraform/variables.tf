
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
  default     = "../../backend"
}

variable "skills_service_code_path" {
  description = "Skillsets service code path."
  type        = string
  default     = "../../custom_skills/pdf_text_image_merge_skill"
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

variable "log_analytics_workspace_name" {
  description = "Log Analytics Name."
  type        = string
  default     = ""
}

variable "search_service_name" {
  description = "Search Service Name."
  type        = string
  default     = ""
}

variable "search_service_location" {
  description = "Search Service Location."
  type        = string
  default     = ""
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
  default     = ""
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
  default     = ""
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
  default     = ""
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
