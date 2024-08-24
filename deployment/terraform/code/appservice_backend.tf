data "archive_file" "backend" {
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

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.user_assigned_identity.user_assigned_identity_id
    ]
  }

  auth_settings {
    enabled = false
  }

  app_settings = {
    ALLOWED_ORIGIN                        = ""
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.application_insights.application_insights_connection_string
    AZURE_AUTH_TENANT_ID                  = ""
    AZURE_AUTHENTICATION_ISSUER_URI       = "https://login.microsoftonline.com//v2.0"
    AZURE_CLIENT_APP_ID                   = ""
    AZURE_CLIENT_APP_SECRET               = ""
    AZURE_DOCUMENTINTELLIGENCE_SERVICE    = "cog-di-i2lzzdw6pvrhi"
    AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS   = "false"
    AZURE_ENABLE_UNAUTHENTICATED_ACCESS   = "false"
    AZURE_ENFORCE_ACCESS_CONTROL          = "false"
    AZURE_OPENAI_API_KEY_OVERRIDE         = module.openai.azurerm_cognitive_account_primary_access_key
    AZURE_OPENAI_API_VERSION              = ""
    AZURE_OPENAI_CHATGPT_DEPLOYMENT       = local.gpt_model_name #"chat"
    AZURE_OPENAI_CHATGPT_MODEL            = local.gpt_model_name
    AZURE_OPENAI_CUSTOM_URL               = ""
    AZURE_OPENAI_EMB_DEPLOYMENT           = "text-embedding-3-large"
    AZURE_OPENAI_EMB_DIMENSIONS           = "1536"
    AZURE_OPENAI_EMB_MODEL_NAME           = "text-embedding-3-large"
    AZURE_OPENAI_GPT4V_DEPLOYMENT         = local.gpt_model_name
    AZURE_OPENAI_GPT4V_MODEL              = local.gpt_model_name
    AZURE_OPENAI_SERVICE                  = local.opeanai_name                                   #"cog-i2lzzdw6pvrhi"
    AZURE_SEARCH_INDEX                    = "${module.ai_search.search_service_name}-index-text" #"gptkbindex"
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
    SCM_DO_BUILD_DURING_DEPLOYMENT        = "True"
    USE_GPT4V                             = "false"
    USE_LOCAL_HTML_PARSER                 = "false"
    USE_LOCAL_PDF_PARSER                  = "false"
    USE_SPEECH_INPUT_BROWSER              = "false"
    USE_SPEECH_OUTPUT_AZURE               = "false"
    USE_SPEECH_OUTPUT_BROWSER             = "false"
    USE_USER_UPLOAD                       = "false"
    USE_VECTORS                           = "true"
    # WEBSITE_HTTPLOGGING_RETENTION_DAYS = "1"

    # WEBSITE_RUN_FROM_PACKAGE       = "0"
    # SCM_DO_BUILD_DURING_DEPLOYMENT = "true"

    # AZURE_STORAGE_ACCOUNT = module.storage_account.storage_account_name
    # AZURE_STORAGE_CONTAINER = local.container_name_text

    # AZURE_SEARCH_INDEX = "${module.ai_search.search_service_name}-index-text"
    # AZURE_SEARCH_SERVICE = module.ai_search.search_service_name
    # AZURE_SEARCH_SEMANTIC_RANKER = "disabled"

    # AZURE_VISION_ENDPOINT  = module.ai_vision.cognitive_account_endpoint
    # AZURE_SEARCH_QUERY_LANGUAGE = "en"
    # AZURE_SEARCH_QUERY_SPELLER ="lexicon"

    # APPLICATIONINSIGHTS_CONNECTION_STRING = module.application_insights.application_insights_connection_string
    # AZURE_SPEECH_SERVICE_ID = ""
    # AZURE_SPEECH_SERVICE_LOCATION = ""
    # USE_SPEECH_INPUT_BROWSER = false
    # USE_SPEECH_OUTPUT_BROWSER = false
    # USE_SPEECH_OUTPUT_AZURE = false

    # OPENAI_HOST = module.openai.cognitive_account_endpoint
    # AZURE_OPENAI_EMB_MODEL_NAME = "text-embedding-3-large"
    # AZURE_OPENAI_EMB_DIMENSIONS = 0

    # AZURE_OPENAI_CHATGPT_MODEL: local.gpt_model_name
    # AZURE_OPENAI_GPT4V_MODEL =local.gpt_model_name

    # AZURE_OPENAI_SERVICE = true
    # AZURE_OPENAI_CHATGPT_DEPLOYMENT = local.gpt_model_name
    # AZURE_OPENAI_EMB_DEPLOYMENT = "text-embedding-3-large"
    # AZURE_OPENAI_GPT4V_DEPLOYMENT = local.gpt_model_name
    # AZURE_OPENAI_API_VERSION = "2024-05-13"
    # AZURE_OPENAI_API_KEY_OVERRIDE = module.openai.azurerm_cognitive_account_primary_access_key
    # AZURE_OPENAI_CUSTOM_URL = ""

    # AZURE_OPENAI_CUSTOM_URL = ""
    # OPENAI_ORGANIZATION = ""

    # AZURE_USE_AUTHENTICATION = false
    # AZURE_ENFORCE_ACCESS_CONTROL = false
    # AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS = false
    # AZURE_ENABLE_UNAUTHENTICATED_ACCESS = false

    # AZURE_SERVER_APP_ID = ""
    # AZURE_SERVER_APP_SECRET = ""
    # AZURE_CLIENT_APP_ID = ""
    # AZURE_CLIENT_APP_SECRET = ""
    # AZURE_TENANT_ID = ""
    # AZURE_AUTH_TENANT_ID = ""
    # AZURE_AUTHENTICATION_ISSUER_URI = ""

    # ALLOWED_ORIGIN = "*"
    # USE_VECTORS = true
    # USE_GPT4V = true
    # USE_USER_UPLOAD = true
    # AZURE_USERSTORAGE_ACCOUNT = module.storage_account.storage_account_name
    # AZURE_USERSTORAGE_CONTAINER = "user_upload"

    # AZURE_DOCUMENTINTELLIGENCE_SERVICE =""
    # USE_LOCAL_PDF_PARSER = false
    # USE_LOCAL_HTML_PARSER = false

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
