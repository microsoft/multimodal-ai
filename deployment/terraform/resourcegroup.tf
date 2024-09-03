# Resource: Resource Group  
resource "azurerm_resource_group" "resource_group" {  
  name     = var.resource_group_name != "" ? var.resource_group_name : "${local.abbrs.resourcesResourceGroups}${var.environment_name}-${local.resourceToken}"  
  location = var.location  
  tags     = local.tags  
}  
  
# # Resource: App Service Plan  
# resource "azurerm_service_plan" "backendAppServicePlan" {  
#   name                = var.appServicePlanName != "" ? var.appServicePlanName : "${local.abbrs.webServerFarms}${local.resourceToken}"  
#   location            = azurerm_resource_group.rg.location  
#   resource_group_name = azurerm_resource_group.rg.name  
#   tags                = local.tags  
  
#   sku_name = var.appServicePlanSku
#   os_type = "Linux"  
# }  
  
# # Resource: App Service (Backend)  
# resource "azurerm_linux_function_app" "backendFunctionApp" {  
#   name                = var.backendServiceName != "" ? var.backendServiceName : "backend-${local.resourceToken}"  
#   location            = azurerm_resource_group.rg.location  
#   resource_group_name = azurerm_resource_group.rg.name  
#   service_plan_id = azurerm_service_plan.backendAppServicePlan.id  
#   storage_account_name       = azurerm_storage_account.main.name
#   storage_account_access_key = azurerm_storage_account.main.primary_access_key
#   builtin_logging_enabled                  = false
#   client_certificate_mode                  = "Required"
#   ftp_publish_basic_authentication_enabled = false
#   webdeploy_publish_basic_authentication_enabled = false
#   tags                = merge(local.tags, { "service-name" = "backend" })  
  
#   site_config {  
#     application_stack {
#       python_version = "3.9"
#     }
#   }  
  
#   app_settings = {
#     FUNCTIONS_WORKER_RUNTIME              = "python"
#     docsBlobStorage                       = azurerm_storage_account.main.primary_connection_string 
#     WEBSITE_RUN_FROM_PACKAGE              = 1 
#     SCM_DO_BUILD_DURING_DEPLOYMENT        = true
#     ENABLE_ORYX_BUILD                     = true
#     ALLOWED_ORIGIN                        = ""
#     APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string 
#     AZURE_AUTHENTICATION_ISSUER_URI       = "https://login.microsoftonline.com//v2.0"
#     AZURE_AUTH_TENANT_ID                  = ""
#     AZURE_CLIENT_APP_ID                   = ""
#     AZURE_CLIENT_APP_SECRET               = ""
#     AZURE_DOCUMENTINTELLIGENCE_KEY        = ""
#     AZURE_DOCUMENTINTELLIGENCE_SERVICE    = ""
#     AZURE_ENABLE_GLOBAL_DOCUMENTS_ACCESS  = "false"
#     AZURE_ENABLE_UNAUTHENTICATED_ACCESS   = "false"
#     AZURE_ENFORCE_ACCESS_CONTROL          = "false"
#     AZURE_OPENAI_API_KEY                  = ""
#     AZURE_OPENAI_API_VERSION              = ""
#     AZURE_OPENAI_CHATGPT_DEPLOYMENT       = "chat"
#     AZURE_OPENAI_CHATGPT_MODEL            = "gpt-35-turbo"
#     AZURE_OPENAI_CUSTOM_URL               = ""
#     AZURE_OPENAI_EMB_DEPLOYMENT           = "embedding"
#     AZURE_OPENAI_EMB_DIMENSIONS           = "1536"
#     AZURE_OPENAI_EMB_MODEL_NAME           = "text-embedding-ada-002"
#     AZURE_OPENAI_GPT4V_DEPLOYMENT         = "gpt-4o"
#     AZURE_OPENAI_GPT4V_MODEL              = "gpt-4o"
#     AZURE_OPENAI_SERVICE                  = ""
#     AZURE_SEARCH_INDEX                    = "gptkbindex"
#     AZURE_SEARCH_QUERY_LANGUAGE           = "en-us"
#     AZURE_SEARCH_QUERY_SPELLER            = "lexicon"
#     AZURE_SEARCH_SEMANTIC_RANKER          = "free"
#     AZURE_SEARCH_SERVICE                  = ""
#     AZURE_SERVER_APP_ID                   = ""
#     AZURE_SERVER_APP_SECRET               = ""
#     AZURE_SPEECH_SERVICE_ID               = ""
#     AZURE_SPEECH_SERVICE_LOCATION         = ""
#     AZURE_STORAGE_ACCOUNT                 = ""
#     AZURE_STORAGE_CONTAINER               = "content"
#     AZURE_TENANT_ID                       = ""
#     AZURE_USERSTORAGE_ACCOUNT             = ""
#     AZURE_USERSTORAGE_CONTAINER           = ""
#     AZURE_USE_AUTHENTICATION              = "false"
#     AZURE_VISION_ENDPOINT                 = "https://cog-cv-jhgj5rcyn7qr2.cognitiveservices.azure.com/"
#     OPENAI_API_KEY                        = ""
#     OPENAI_HOST                           = "azure"
#     OPENAI_ORGANIZATION                   = ""
#     PYTHONUNBUFFERED                      = "1"
#     PYTHON_ENABLE_GUNICORN_MULTIWORKERS   = "true"
#     SEARCH_KEY                            = ""
#     USE_GPT4V                             = "true"
#     USE_LOCAL_HTML_PARSER                 = "false"
#     USE_LOCAL_PDF_PARSER                  = "false"
#     USE_SPEECH_INPUT_BROWSER              = "false"
#     USE_SPEECH_OUTPUT_AZURE               = "false"
#     USE_SPEECH_OUTPUT_BROWSER             = "false"
#     USE_USER_UPLOAD                       = "true"
#     USE_VECTORS                           = "true"
#   }

#   identity {
#     type = "SystemAssigned"
#   }
# }  


# # resource "azurerm_function_app_function" "backendFunction" {
# #   config_json = jsonencode({
# #     bindings = [{
# #       authLevel = "function"
# #       direction = "IN"
# #       name      = "req"
# #       route     = "{*route}"
# #       type      = "httpTrigger"
# #       }, {
# #       direction = "OUT"
# #       name      = "$return"
# #       type      = "http"
# #     }]
# #     entryPoint        = "main"
# #     functionDirectory = "/home/site/wwwroot"
# #     language          = "python"
# #     name              = "main"
# #     scriptFile        = "function_app.py"
# #   })
# #   function_app_id = azurerm_linux_function_app.backendFunctionApp.id
# #   name            = "main"
# # }


# # zip code into a package
# data "archive_file" "backend_deploy_package" {
#   type        = "zip"
#   source_dir  = "../../backend"
#   output_path = "backend.zip"
# }

# # deploy code command requires azure cli
# #    "az webapp deployment source config-zip --resource-group rg-mmai-536e95055e190fbc --name backend-536e95055e190fbc --src backend.zip"
# locals {
#     deploy_func_app_cmd = "az functionapp deployment source config-zip --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_linux_function_app.backendFunctionApp.name} --src ${data.archive_file.backend_deploy_package.output_path}"
# }

# #deploy code
# resource "null_resource" "function_app_publish" {
#   provisioner "local-exec" {
#     command = local.deploy_func_app_cmd
#   }
#   triggers = {
#     input_json = filemd5(data.archive_file.backend_deploy_package.output_path)
#     deploy_func_app_cmd = local.deploy_func_app_cmd
#   }
#   depends_on = [local.deploy_func_app_cmd]
# }

# # resource "azurerm_storage_blob" "deploy_package_storage" {
# #   name = "${filesha256(var.archive_file.output_path)}.zip"
# #   storage_account_name = azurerm_storage_account.main.name
# #   storage_container_name = azurerm_storage_container.deployment_package_container.name
# #   type = "Block"
# #   source = var.archive_file.output_path
# # }


# # Resource: Storage Account  
# resource "azurerm_storage_account" "main" {  
#   name                     = var.storageAccountName != "" ? var.storageAccountName : substr("${local.abbrs.storageStorageAccounts}${local.resourceToken}",0,24)  
#   resource_group_name      = azurerm_resource_group.rg.name  
#   location                 = azurerm_resource_group.rg.location  
#   tags                     = local.tags  
#   account_tier             = "Standard"  
#   account_replication_type = "LRS"  
  
#   blob_properties {  
#     delete_retention_policy {  
#       days    = 2  
#       permanent_delete_enabled = true  
#     }  
#   }  
  
#   identity {  
#     type = "SystemAssigned"  
#   }  
  
#   network_rules {  
#     default_action = "Deny"  
#   }  
  
# }  
  
# # Storage Container  
# resource "azurerm_storage_container" "main" {  
#   name                  = var.storageContainerName  
#   storage_account_name  = azurerm_storage_account.main.name  
#   container_access_type = "private"  
# }  
  
# # resource "azurerm_storage_container" "deployment_package_container" {  
# #   name                  = var.storagePackageContainerName
# #   storage_account_name  = azurerm_storage_account.main.name  
# #   container_access_type = "private"  
# # }  
  
# # Resource: Search Service  
# resource "azurerm_search_service" "main" {  
#   name                = var.searchServiceName != "" ? var.searchServiceName : "${local.abbrs.searchServices}${local.resourceToken}"  
#   resource_group_name = azurerm_resource_group.rg.name  
#   location            = var.searchServiceLocation != "" ? var.searchServiceLocation : azurerm_resource_group.rg.location  
#   sku                 = var.searchServiceSkuName  
#   semantic_search_sku         = "free"
#   identity {
#     type = "SystemAssigned"
#   }

# }  
  
# # Resource: Application Insights  
# resource "azurerm_application_insights" "main" {  
#   name                = var.applicationInsightsName != "" ? var.applicationInsightsName : "${local.abbrs.insightsComponents}${local.resourceToken}"  
#   resource_group_name = azurerm_resource_group.rg.name  
#   location            = azurerm_resource_group.rg.location  
#   application_type    = "web"
#   workspace_id = azurerm_log_analytics_workspace.main.id
# }  
  
# # Resource: Log Analytics Workspace  
# resource "azurerm_log_analytics_workspace" "main" {  
#   name                = var.logAnalyticsName != "" ? var.logAnalyticsName : "${local.abbrs.operationalInsightsWorkspaces}${local.resourceToken}"  
#   location            = azurerm_resource_group.rg.location  
#   resource_group_name = azurerm_resource_group.rg.name  
#   retention_in_days   = 30  
#   sku                 = "PerGB2018"  
# }  
  
# # Data Source (Client Configuration)  
# data "azurerm_client_config" "current" {}  
  
# # Random ID Generator  
# resource "random_id" "main" {  
#   keepers = {  
#     env_name = var.environmentName  
#   }  
#   byte_length = 8  
# }  
