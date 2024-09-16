variable "subscription_id" {
  description = "subscription_id"
  type        = string
}

variable "environment_name" {
  description = "Name of the the environment, used to generate a short unique hash used in all resources."
  type        = string
}

variable "location" {
  description = "Primary location for all resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name."
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
  default     = "../../skills"
}

variable "appservice_plan_sku" {
  description = "App Service Plan Sku Name."
  type        = string
  default     = "S2" # linux consumption plans does not support website_run_from_package = 1 setting
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
  description = "Specifies datasource name"
  type        = string
  default     = ""
}

variable "search_service_index_name" {
  description = "Specifies index name"
  type        = string
  default     = ""
}

variable "search_service_indexer_name" {
  description = "Specifies indexer name"
  type        = string
  default     = ""
}

variable "search_service_skillset_name" {
  description = "Specifies skillset name"
  type        = string
  default     = ""
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

variable "knowledgestore_storage_container_name" {
  description = "Specifies knowledge resource contaner name."
  type        = string
  sensitive   = false
  default     = "docs"
}


variable "openai_service_name" {
  description = "Specifies the sku name of the cognitive service."
  type        = string
  sensitive   = false
  default     = ""
}

variable "openai_service_sku" {
  description = "Specifies the sku name of the cognitive service."
  type        = string
  sensitive   = false
  default     = "S0"
  validation {
    condition     = length(var.openai_service_sku) >= 1
    error_message = "Please specify a valid sku name."
  }
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
  default     = "S0"
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

variable "form_recognizer_sku" {
  description = "Specifies the sku name of the cognitive service."
  type        = string
  sensitive   = false
  default     = "F0"
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

variable "computer_vision_sku" {
  description = "Specifies the sku name of the cognitive service."
  type        = string
  sensitive   = false
  default     = "S1"
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
        capacity = 1
      }
    },
    {
      name = "text-embedding-ada-002"
      model = {
        format  = "OpenAI"
        version = "2"
      }
      sku = {
        capacity = 1
      }
    },
    {
      name = "gpt-35-turbo"
      model = {
        format  = "OpenAI"
        version = "0613"
      }
      sku = {
        capacity = 1
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
  default     = "content"
}



# ###################################################################################################

variable "azure_auth_tenant_id" {
  description = "AZURE_AUTH_TENANT_ID app service configuration value."
  type        = string
  default     = ""
}

variable "azure_client_app_id" {
  description = "AZURE_CLIENT_APP_ID app service configuration value."
  type        = string
  default     = ""
}

variable "azure_client_app_secret" {
  description = "AZURE_CLIENT_APP_SECRET app service configuration value."
  type        = string
  default     = ""
}

variable "azure_documentintelligence_key" {
  description = "AZURE_DOCUMENTINTELLIGENCE_KEY app service configuration value."
  type        = string
  default     = ""
}

variable "azure_documentintelligence_service" {
  description = "AZURE_DOCUMENTINTELLIGENCE_SERVICE app service configuration value."
  type        = string
  default     = ""
}

variable "azure_enable_global_documents_access" {
  description = "AZURE_ENABLE_GLOBAL_DOCUMENTS_ACCESS app service configuration value."
  type        = string
  default     = ""
}

variable "azure_enable_unauthenticated_access" {
  description = "AZURE_ENABLE_UNAUTHENTICATED_ACCESS app service configuration value."
  type        = string
  default     = ""
}

variable "azure_enforce_access_control" {
  description = "AZURE_ENFORCE_ACCESS_CONTROL app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_api_key" {
  description = "AZURE_OPENAI_API_KEY app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_api_version" {
  description = "AZURE_OPENAI_API_VERSION app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_chatgpt_deployment" {
  description = "AZURE_OPENAI_CHATGPT_DEPLOYMENT app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_chatgpt_model" {
  description = "AZURE_OPENAI_CHATGPT_MODEL app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_custom_url" {
  description = "AZURE_OPENAI_CUSTOM_URL app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_emb_deployment" {
  description = "AZURE_OPENAI_EMB_DEPLOYMENT app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_emb_dimensions" {
  description = "AZURE_OPENAI_EMB_DIMENSIONS app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_emb_model_name" {
  description = "AZURE_OPENAI_EMB_MODEL_NAME app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_gpt4v_deployment" {
  description = "AZURE_OPENAI_GPT4V_DEPLOYMENT app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_gpt4v_model" {
  description = "AZURE_OPENAI_GPT4V_MODEL app service configuration value."
  type        = string
  default     = ""
}

variable "azure_openai_service" {
  description = "AZURE_OPENAI_SERVICE app service configuration value."
  type        = string
  default     = ""
}

variable "azure_search_index" {
  description = "AZURE_SEARCH_INDEX app service configuration value."
  type        = string
  default     = ""
}

variable "azure_search_query_language" {
  description = "AZURE_SEARCH_QUERY_LANGUAGE app service configuration value."
  type        = string
  default     = ""
}

variable "azure_search_query_speller" {
  description = "AZURE_SEARCH_QUERY_SPELLER app service configuration value."
  type        = string
  default     = ""
}

variable "azure_search_semantic_ranker" {
  description = "AZURE_SEARCH_SEMANTIC_RANKER app service configuration value."
  type        = string
  default     = ""
}

variable "azure_server_app_id" {
  description = "AZURE_SERVER_APP_ID app service configuration value."
  type        = string
  default     = ""
}

variable "azure_server_app_secret" {
  description = "AZURE_SERVER_APP_SECRET app service configuration value."
  type        = string
  default     = ""
}

variable "azure_speech_service_id" {
  description = "AZURE_SPEECH_SERVICE_ID app service configuration value."
  type        = string
  default     = ""
}

variable "azure_speech_service_location" {
  description = "AZURE_SPEECH_SERVICE_LOCATION app service configuration value."
  type        = string
  default     = ""
}

variable "azure_storage_account" {
  description = "AZURE_STORAGE_ACCOUNT app service configuration value."
  type        = string
  default     = ""
}

variable "azure_storage_container" {
  description = "AZURE_STORAGE_CONTAINER app service configuration value."
  type        = string
  default     = ""
}

variable "azure_tenant_id" {
  description = "AZURE_TENANT_ID app service configuration value."
  type        = string
  default     = ""
}

variable "azure_userstorage_account" {
  description = "AZURE_USERSTORAGE_ACCOUNT app service configuration value."
  type        = string
  default     = ""
}

variable "azure_userstorage_container" {
  description = "AZURE_USERSTORAGE_CONTAINER app service configuration value."
  type        = string
  default     = ""
}

variable "azure_use_authentication" {
  description = "AZURE_USE_AUTHENTICATION app service configuration value."
  type        = string
  default     = ""
}

variable "azure_vision_endpoint" {
  description = "AZURE_VISION_ENDPOINT app service configuration value."
  type        = string
  default     = ""
}

variable "enable_oryx_build" {
  description = "ENABLE_ORYX_BUILD app service configuration value."
  type        = string
  default     = ""
}

variable "openai_api_key" {
  description = "OPENAI_API_KEY app service configuration value."
  type        = string
  default     = ""
}

variable "openai_host" {
  description = "OPENAI_HOST app service configuration value."
  type        = string
  default     = ""
}

variable "openai_organization" {
  description = "OPENAI_ORGANIZATION app service configuration value."
  type        = string
  default     = ""
}

variable "pythonunbuffered" {
  description = "PYTHONUNBUFFERED app service configuration value."
  type        = string
  default     = ""
}

variable "python_enable_gunicorn_multiworkers" {
  description = "PYTHON_ENABLE_GUNICORN_MULTIWORKERS app service configuration value."
  type        = string
  default     = ""
}

variable "search_key" {
  description = "SEARCH_KEY app service configuration value."
  type        = string
  default     = ""
}

variable "use_gpt4v" {
  description = "USE_GPT4V app service configuration value."
  type        = string
  default     = ""
}

variable "use_local_html_parser" {
  description = "USE_LOCAL_HTML_PARSER app service configuration value."
  type        = string
  default     = ""
}

variable "use_local_pdf_parser" {
  description = "USE_LOCAL_PDF_PARSER app service configuration value."
  type        = string
  default     = ""
}

variable "use_speech_input_browser" {
  description = "USE_SPEECH_INPUT_BROWSER app service configuration value."
  type        = string
  default     = ""
}

variable "use_speech_output_azure" {
  description = "USE_SPEECH_OUTPUT_AZURE app service configuration value."
  type        = string
  default     = ""
}

variable "use_speech_output_browser" {
  description = "USE_SPEECH_OUTPUT_BROWSER app service configuration value."
  type        = string
  default     = ""
}

variable "use_user_upload" {
  description = "USE_USER_UPLOAD app service configuration value."
  type        = string
  default     = ""
}

variable "use_vectors" {
  description = "USE_VECTORS app service configuration value."
  type        = string
  default     = ""
}
