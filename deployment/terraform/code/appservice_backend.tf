data "archive_file" "backend" {
  depends_on  = [null_resource.npm_build]
  type        = "zip"
  source_dir  = "../../../azure-search-openai-demo/app/backend/" # Replace with the path to your application code
  output_path = "${path.module}/${format("appservice_backend-%s.zip", formatdate("YYYY-MM-DD'-'hh_mm_ss", timestamp()))}"
}

resource "azurerm_linux_web_app" "web_app_backend" {
  name                = local.app_service_backend_name
  location            = var.location
  resource_group_name = azurerm_resource_group.mmai.name
  service_plan_id     = module.appserviceplan.azurerm_service_plan_id

  public_network_access_enabled = true

  site_config {
    always_on                = true
    app_command_line         = "python3 -m gunicorn main:app"
    remote_debugging_enabled = true
    application_stack {
      python_version = "3.11"
    }
  }

  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     module.user_assigned_identity.user_assigned_identity_id
  #   ]
  # }

  identity {
    type = "SystemAssigned"
  }

  auth_settings {
    enabled = false
  }

  app_settings = {
    APP_LOG_LEVEL                         = "INFO"
    ALLOWED_ORIGIN                        = ""
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.application_insights.application_insights_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY        = module.application_insights.application_insights_instrumentation_key
    AZURE_AUTH_TENANT_ID                  = ""
    AZURE_AUTHENTICATION_ISSUER_URI       = "https://login.microsoftonline.com//v2.0"
    AZURE_CLIENT_APP_ID                   = ""
    AZURE_CLIENT_APP_SECRET               = ""
    AZURE_DOCUMENTINTELLIGENCE_SERVICE    = local.document_intelligence_name
    AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS   = "false"
    AZURE_ENABLE_UNAUTHENTICATED_ACCESS   = "false"
    AZURE_ENFORCE_ACCESS_CONTROL          = "false"
    AZURE_OPENAI_API_KEY_OVERRIDE         = module.openai.azurerm_cognitive_account_primary_access_key
    AZURE_OPENAI_API_VERSION              = ""
    AZURE_OPENAI_CHATGPT_DEPLOYMENT       = local.chat_deployment
    AZURE_OPENAI_CHATGPT_MODEL            = local.chat_model
    AZURE_OPENAI_CUSTOM_URL               = ""
    AZURE_OPENAI_EMB_DEPLOYMENT           = local.embedding_deployment
    AZURE_OPENAI_EMB_DIMENSIONS           = "1536"
    AZURE_OPENAI_EMB_MODEL_NAME           = local.embedding_model
    AZURE_OPENAI_GPT4V_DEPLOYMENT         = ""                 #local.gpt4v_deployment
    AZURE_OPENAI_GPT4V_MODEL              = ""                 #local.gpt4v_model
    AZURE_OPENAI_SERVICE                  = local.opeanai_name #"cog-i2lzzdw6pvrhi"
    AZURE_SEARCH_INDEX                    = local.ai_search_index_name
    AZURE_SEARCH_QUERY_LANGUAGE           = "en-us"
    AZURE_SEARCH_QUERY_SPELLER            = "lexicon"
    AZURE_SEARCH_SEMANTIC_RANKER          = "free"
    AZURE_SEARCH_SERVICE                  = local.ai_search_name #"cog-i2lzzdw6pvrhi"
    AZURE_SERVER_APP_ID                   = ""
    AZURE_SERVER_APP_SECRET               = ""
    AZURE_SPEECH_SERVICE_ID               = ""
    AZURE_SPEECH_SERVICE_LOCATION         = ""
    AZURE_STORAGE_ACCOUNT                 = local.storage_account_name
    AZURE_STORAGE_CONTAINER               = local.container_name_text
    AZURE_TENANT_ID                       = ""
    AZURE_USE_AUTHENTICATION              = "false"
    AZURE_USERSTORAGE_ACCOUNT             = ""
    AZURE_USERSTORAGE_CONTAINER           = ""
    AZURE_VISION_ENDPOINT                 = ""
    ENABLE_ORYX_BUILD                     = "True"
    OPENAI_API_KEY                        = ""
    OPENAI_HOST                           = "azure"
    OPENAI_ORGANIZATION                   = ""
    PYTHON_ENABLE_GUNICORN_MULTIWORKERS   = "true"
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "true"
    USE_GPT4V                             = "false"
    USE_LOCAL_HTML_PARSER                 = "false"
    USE_LOCAL_PDF_PARSER                  = "false"
    USE_SPEECH_INPUT_BROWSER              = "false"
    USE_SPEECH_OUTPUT_AZURE               = "false"
    USE_SPEECH_OUTPUT_BROWSER             = "false"
    USE_USER_UPLOAD                       = "false"
    USE_VECTORS                           = "true"

  }
}

resource "null_resource" "web_app_deployment_backend" {

  depends_on = [azurerm_linux_web_app.web_app_backend]

  triggers = {
    file = data.archive_file.backend.output_base64sha256
  }
  provisioner "local-exec" {
    command = <<-EOF
    az webapp deploy --clean --restart \
    --resource-group ${azurerm_resource_group.mmai.name} \
    --name ${local.app_service_backend_name} \
    --type zip \
    --src-path ${data.archive_file.backend.output_path}
EOF
  }
}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories_linux_function_app_backend" {
  resource_id = azurerm_linux_web_app.web_app_backend.id
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting_linux_function_app_backend" {
  name                       = "logAnalytics"
  target_resource_id         = azurerm_linux_web_app.web_app_backend.id
  log_analytics_workspace_id = module.azure_log_analytics.log_analytics_id

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories_linux_function_app_backend.log_category_groups
    content {
      category_group = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories_linux_function_app_backend.metrics
    content {
      category = entry.value
      enabled  = true
    }
  }
}

output "web_app_backend" {
  value = "https://${azurerm_linux_web_app.web_app_backend.default_hostname}"
}

resource "azurerm_role_assignment" "webapp_openai_contributor" {
  scope                = module.openai.azurerm_cognitive_account_service_id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = azurerm_linux_web_app.web_app_backend.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "webapp_openai_user" {
  scope                = module.openai.azurerm_cognitive_account_service_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_linux_web_app.web_app_backend.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "webapp_aivision_contirbutor" {
  scope                = module.ai_vision.azurerm_cognitive_account_service_id
  role_definition_name = "Cognitive Services Custom Vision Contributor"
  principal_id         = azurerm_linux_web_app.web_app_backend.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "webapp_storage_blob_contirbutor" {
  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.web_app_backend.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "webapp_storage_aisearch_contirbutor" {
  scope                = module.ai_search.search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_linux_web_app.web_app_backend.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "webapp_storage_aisearch_search_index_data_reader" {
  scope                = module.ai_search.search_service_id
  role_definition_name = "Search Index Data Reader"
  principal_id         = azurerm_linux_web_app.web_app_backend.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "openai_aisearch_contirbutor" {
  scope                = module.ai_search.search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = module.openai.azurerm_cognitive_account_principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "openai_aisearch_index_data_reader" {
  scope                = module.ai_search.search_service_id
  role_definition_name = "Search Index Data Reader"
  principal_id         = module.openai.azurerm_cognitive_account_principal_id
  principal_type       = "ServicePrincipal"
}

# Current user - data plane permissions

resource "azurerm_role_assignment" "current_user_openai_contributor" {
  count                = var.environment == "dev" ? 1 : 0
  scope                = module.openai.azurerm_cognitive_account_service_id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

resource "azurerm_role_assignment" "current_user_aivision_contirbutor" {
  count                = var.environment == "dev" ? 1 : 0
  scope                = module.ai_vision.azurerm_cognitive_account_service_id
  role_definition_name = "Cognitive Services Custom Vision Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

resource "azurerm_role_assignment" "current_user_aisearch_contirbutor" {
  count                = var.environment == "dev" ? 1 : 0
  scope                = module.ai_search.search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

resource "azurerm_role_assignment" "current_user_storage_aisearch_search_index_data_reader" {
  count                = var.environment == "dev" ? 1 : 0
  scope                = module.ai_search.search_service_id
  role_definition_name = "Search Index Data Reader"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}