module "applicationinsights" {
  source = "./modules/applicationinsights"

  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  application_insights_name  = var.application_insights_name != "" ? var.application_insights_name : "${local.abbrs.insightsComponents}${local.resourceToken}"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  app_insights_internet_ingestion_enabled    = false
  app_insights_internet_query_enabled        = false
  app_insights_local_authentication_disabled = false
}

module "ampls" {
  source = "./modules/ampls"

  location                      = var.location
  tags                          = local.tags
  resource_group_name           = azurerm_resource_group.resource_group.name
  ampls_name                    = var.azure_monitor_private_link_scope_name != "" ? var.azure_monitor_private_link_scope_name : "${local.abbrs.azureMonitorPrivateLinksScope}${local.resourceToken}"
  ampls_ingestion_access_mode   = "PrivateOnly"
  ampls_query_access_mode       = "PrivateOnly"
  connectivity_delay_in_seconds = var.connectivity_delay_in_seconds
  vnet_location                 = data.azurerm_virtual_network.virtual_network.location
  subnet_id                     = azapi_resource.subnet_private_endpoints.id
  private_dns_zone_list_ampls = toset([
    var.private_dns_zone_id_monitor,
    var.private_dns_zone_id_oms_opsinsights,
    var.private_dns_zone_id_ods_opsinsights,
    var.private_dns_zone_id_automation,
    var.private_dns_zone_id_blob
  ])

}
module "ampls_scopedservice_appinsights" {
  source     = "./modules/ampls_scoped_service"
  depends_on = [module.ampls]

  location                  = var.location
  resource_group_name       = azurerm_resource_group.resource_group.name
  ampls_scoped_service_name = var.ampls_scoped_service_appinsights != "" ? var.ampls_scoped_service_appinsights : "${local.abbrs.azureMonitorPrivateLinksScope}appinsights"
  ampls_scope_name          = module.ampls.azurerm_monitor_private_link_scope_name
  azure_monitor_resource_id = var.log_analytics_workspace_id
}

module "ampls_scopedservice_law" {
  source     = "./modules/ampls_scoped_service"
  depends_on = [module.ampls_scopedservice_appinsights]

  location                  = var.location
  resource_group_name       = azurerm_resource_group.resource_group.name
  ampls_scoped_service_name = var.ampls_scoped_service_law != "" ? var.ampls_scoped_service_law : "${local.abbrs.azureMonitorPrivateLinksScope}law"
  ampls_scope_name          = module.ampls.azurerm_monitor_private_link_scope_name
  azure_monitor_resource_id = module.applicationinsights.application_insights_id
}

module "keyvault" {
  source                     = "./modules/keyvault"
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  key_vault_name             = var.key_vault_name != "" ? var.key_vault_name : "${local.abbrs.keyVaultVaults}${local.resourceToken}"
  key_vault_sku_name         = var.key_vault_sku_name

  key_vault_secrets = var.webapp_auth_settings.enable_auth == false ? [] : concat(
    [
      {
        secret_name  = var.webapp_auth_settings.server_app.app_secret_name == "" ? module.backend_webapp.server_app_secret_name : var.webapp_auth_settings.server_app.app_secret_name
        secret_value = var.webapp_auth_settings.server_app.app_secret_name == "" ? module.backend_webapp.server_app_password : var.webapp_auth_settings.server_app.app_secret_value
      }
    ]
    ,
    [
      {
        secret_name  = var.webapp_auth_settings.client_app.app_secret_name == "" ? module.backend_webapp.client_app_secret_name : var.webapp_auth_settings.client_app.app_secret_name
        secret_value = var.webapp_auth_settings.client_app.app_secret_name == "" ? module.backend_webapp.client_app_password : var.webapp_auth_settings.client_app.app_secret_value
      }
    ]
  )

  #   cmk_uai_id                    = module.user_assigned_identity.user_assigned_identity_id
  subnet_id                     = azapi_resource.subnet_private_endpoints.id
  private_dns_zone_id_key_vault = var.private_dns_zone_id_vault
  vnet_location                 = data.azurerm_virtual_network.virtual_network.location
  public_network_access_enabled = false
}



module "storage" {
  source               = "./modules/storage"
  location             = var.location
  tags                 = local.tags
  resource_group_name  = azurerm_resource_group.resource_group.name
  storage_account_name = var.storage_account_name != "" ? var.storage_account_name : substr("${local.abbrs.storageStorageAccounts}${local.resourceToken}", 0, 24)
  #storage_account_container_names           = [var.storage_container_name_content, var.storage_container_name_knowledgestore]
  storage_account_container_names           = [var.storage_container_name_content]
  storage_account_shared_access_key_enabled = false
  log_analytics_workspace_id                = var.log_analytics_workspace_id
  subnet_id                                 = azapi_resource.subnet_private_endpoints.id
  private_dns_zone_id_blob                  = var.private_dns_zone_id_blob
  private_dns_zone_id_file                  = var.private_dns_zone_id_file
  vnet_location                             = data.azurerm_virtual_network.virtual_network.location
  public_network_access_enabled             = false
  network_bypass                            = ["AzureServices"]
  private_endpoint_subresource_names        = ["blob", "file"]
  network_private_link_access = [
    "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Security/datascanners/StorageDataScanner"
  ]
}


module "skills" {
  source                                            = "./modules/function"
  location                                          = var.location
  tags                                              = local.tags
  resource_group_name                               = azurerm_resource_group.resource_group.name
  subscription_id                                   = data.azurerm_client_config.current.subscription_id
  log_analytics_workspace_id                        = var.log_analytics_workspace_id
  function_name                                     = var.skills_service_name != "" ? var.skills_service_name : "skills-${local.resourceToken}"
  function_sku                                      = var.appservice_plan_sku
  function_application_insights_connection_string   = module.applicationinsights.application_insights_connection_string
  function_application_insights_instrumentation_key = module.applicationinsights.application_insights_instrumentation_key
  function_key_vault_id                             = module.keyvault.key_vault_id
  function_code_path                                = var.skills_service_code_path
  function_storage_account_id                       = module.storage.storage_account_id
  skills_function_appregistration_client_id         = var.skills_function_appregistration_client_id

  private_subnet_id         = azapi_resource.subnet_private_endpoints.id
  integration_subnet_id     = azapi_resource.subnet_web.id
  private_dns_zone_id_sites = var.private_dns_zone_id_sites
  vnet_location             = data.azurerm_virtual_network.virtual_network.location

  function_application_settings = {
    FUNCTIONS_WORKER_RUNTIME      = "python"
    PYTHONUNBUFFERED              = "1"
    DOCUMENT_INTELLIGENCE_SERVICE = module.document_intelligence.cognitive_services_name
    FUNCTIONS_EXTENSION_VERSION   = "~4"
  }
}

module "backend_webapp" {
  source                                          = "./modules/webapp"
  location                                        = var.location
  tags                                            = local.tags
  resource_group_name                             = azurerm_resource_group.resource_group.name
  subscription_id                                 = data.azurerm_client_config.current.subscription_id
  log_analytics_workspace_id                      = var.log_analytics_workspace_id
  webapp_name                                     = var.backend_service_name != "" ? var.backend_service_name : "backend-${local.resourceToken}"
  webapp_sku                                      = var.appservice_plan_sku
  webapp_application_insights_connection_string   = module.applicationinsights.application_insights_connection_string
  webapp_application_insights_instrumentation_key = module.applicationinsights.application_insights_instrumentation_key
  webapp_key_vault_id                             = module.keyvault.key_vault_id
  webapp_code_path                                = var.backend_service_code_path
  enable_auth                                     = var.webapp_auth_settings.enable_auth
  client_app_id                                   = var.webapp_auth_settings.client_app.app_id
  server_app_id                                   = var.webapp_auth_settings.server_app.app_id
  resource_token                                  = local.resourceToken
  client_secret_setting_name                      = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"

  private_subnet_id         = azapi_resource.subnet_private_endpoints.id
  integration_subnet_id     = azapi_resource.subnet_web.id
  private_dns_zone_id_sites = var.private_dns_zone_id_sites
  vnet_location             = data.azurerm_virtual_network.virtual_network.location

  webapp_application_settings = {
    AZURE_STORAGE_ACCOUNT               = module.storage.storage_account_name
    AZURE_STORAGE_CONTAINER             = var.storage_container_name_content
    AZURE_SEARCH_INDEX                  = module.aisearch.search_service_index_name
    AZURE_SEARCH_SERVICE                = module.aisearch.search_service_name
    AZURE_SEARCH_SEMANTIC_RANKER        = "standard"
    AZURE_VISION_ENDPOINT               = module.computer_vision.cognitive_account_endpoint
    AZURE_SEARCH_QUERY_LANGUAGE         = "en-us"
    AZURE_SEARCH_QUERY_SPELLER          = "lexicon"
    OPENAI_HOST                         = "azure"
    AZURE_OPENAI_EMB_MODEL_NAME         = var.azure_openai_emb_model_name
    AZURE_OPENAI_EMB_DIMENSIONS         = var.azure_openai_emb_dimensions
    AZURE_OPENAI_CHATGPT_MODEL          = var.azure_openai_chatgpt_model_name
    AZURE_OPENAI_GPT4V_MODEL            = var.azure_openai_gpt4v_model_name
    AZURE_OPENAI_SERVICE                = module.aoai.cognitive_account_name
    AZURE_OPENAI_CHATGPT_DEPLOYMENT     = var.azure_openai_chatgpt_deployment_name
    AZURE_OPENAI_EMB_DEPLOYMENT         = var.azure_openai_emb_deployment_name
    AZURE_OPENAI_GPT4V_DEPLOYMENT       = var.azure_openai_gpt4v_deployment_name
    USE_VECTORS                         = true
    USE_GPT4V                           = true
    PYTHON_ENABLE_GUNICORN_MULTIWORKERS = true
    SCM_DO_BUILD_DURING_DEPLOYMENT      = true
    ENABLE_ORYX_BUILD                   = true
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = false
    PYTHONUNBUFFERED                    = "1"

    AZURE_USE_AUTHENTICATION = var.webapp_auth_settings.enable_auth
    # AZURE_SERVER_APP_ID= <this value is set within module.locals>
    AZURE_SERVER_APP_SECRET                  = var.webapp_auth_settings.enable_auth ? "@Microsoft.KeyVault(VaultName=${module.keyvault.key_vault_name};SecretName=${var.webapp_auth_settings.server_app.app_id == "" && var.webapp_auth_settings.server_app.app_secret_name == "" ? "serverapp-secret-${local.resourceToken}" : var.webapp_auth_settings.server_app.app_secret_name})" : ""
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET = var.webapp_auth_settings.enable_auth ? "@Microsoft.KeyVault(VaultName=${module.keyvault.key_vault_name};SecretName=${var.webapp_auth_settings.client_app.app_id == "" && var.webapp_auth_settings.client_app.app_secret_name == "" ? "clientapp-secret-${local.resourceToken}" : var.webapp_auth_settings.client_app.app_secret_name})" : ""
    # AZURE_CLIENT_APP_ID= <this value is set within module.locals>
    AZURE_AUTH_TENANT_ID                = data.azurerm_client_config.current.tenant_id
    AZURE_ENFORCE_ACCESS_CONTROL        = var.webapp_auth_settings.enable_access_control
    AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS = true
    AZURE_ENABLE_UNAUTHENTICATED_ACCESS = !var.webapp_auth_settings.enable_auth
    AZURE_AUTHENTICATION_ISSUER_URI     = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
  }

  webapp_build_command = <<EOT
      cd ../../../frontend
      npm install
      npm run build
  EOT
}

module "aisearch" {
  source                                = "./modules/aisearch"
  location                              = var.search_service_location != "" ? var.search_service_location : var.location
  tags                                  = local.tags
  resource_group_name                   = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id            = var.log_analytics_workspace_id
  search_service_name                   = var.search_service_name != "" ? var.search_service_name : "${local.abbrs.searchServices}${local.resourceToken}"
  search_service_sku                    = var.search_service_sku
  semantic_search_sku                   = var.semantic_search_sku
  search_service_partition_count        = var.search_service_partition_count
  search_service_replica_count          = var.search_service_replica_count
  storage_account_id                    = module.storage.storage_account_id
  storage_container_name_content        = var.storage_container_name_content
  search_service_datasource_name        = var.search_service_datasource_name != "" ? var.search_service_datasource_name : "${local.abbrs.searchServices}ds-${local.resourceToken}"
  search_service_index_name             = var.search_service_index_name != "" ? var.search_service_index_name : "${local.abbrs.searchServices}ind-${local.resourceToken}"
  search_service_indexer_name           = var.search_service_indexer_name != "" ? var.search_service_indexer_name : "${local.abbrs.searchServices}inder-${local.resourceToken}"
  search_service_skillset_name          = var.search_service_skillset_name != "" ? var.search_service_skillset_name : "${local.abbrs.searchServices}skl-${local.resourceToken}"
  azure_openai_endpoint                 = module.aoai.cognitive_account_endpoint
  azure_openai_text_deployment_id       = var.azure_openai_text_deployment_id
  azure_openai_text_model_name          = var.azure_openai_text_model_name
  openai_account_id                     = module.aoai.cognitive_account_id
  cognitive_services_endpoint           = module.cognitive_service.cognitive_account_endpoint
  computer_vision_endpoint              = module.computer_vision.cognitive_account_endpoint
  pdf_merge_customskill_endpoint        = "https://${module.skills.linux_function_app_default_hostname}/api/pdf_text_image_merge_skill"
  knowledgestore_storage_account_id     = module.storage.storage_account_id
  storage_container_name_knowledgestore = var.storage_container_name_knowledgestore
  function_app_id                       = module.skills.skills_function_appregistration_client_id
  public_network_access_enabled         = false
  vnet_location                         = data.azurerm_virtual_network.virtual_network.location
  subnet_id                             = azapi_resource.subnet_private_endpoints.id
  private_dns_zone_id_ai_search         = var.private_dns_zone_id_ai_search
  vision_id                             = module.computer_vision.cognitive_account_id
  form_recognizer_id                    = module.document_intelligence.cognitive_account_id
  cognitive_account_id                  = module.cognitive_service.cognitive_account_id
  function_id                           = module.skills.linux_function_app_id

  depends_on = [module.aoai, module.cognitive_service, module.storage, module.skills, module.computer_vision]
}


resource "null_resource" "update_function_app_allowed_applications" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${var.subscription_id != "" ? "az account set -s ${var.subscription_id}" : ""}
      az webapp auth update --resource-group ${azurerm_resource_group.resource_group.name} --name ${module.skills.linux_function_app_name} --set identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedApplications=[${module.aisearch.managed_identity_application_id}]
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.aisearch]
}

module "aoai" {
  source                             = "./modules/aoai"
  location                           = var.openai_service_location != "" ? var.openai_service_location : var.location
  tags                               = local.tags
  resource_group_name                = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id         = var.log_analytics_workspace_id
  cognitive_service_name             = var.openai_service_name != "" ? var.openai_service_name : "${local.abbrs.cognitiveServicesOpenAI}${local.resourceToken}"
  cognitive_service_kind             = "OpenAI"
  cognitive_service_sku              = var.openai_service_sku
  aoai_deployments                   = var.aoai_deployments
  local_auth_enabled                 = false
  connectivity_delay_in_seconds      = var.connectivity_delay_in_seconds
  vnet_location                      = data.azurerm_virtual_network.virtual_network.location
  subnet_id                          = azapi_resource.subnet_private_endpoints.id
  public_network_access_enabled      = false
  outbound_network_access_restricted = true
  private_dns_zone_id_open_ai        = var.private_dns_zone_id_open_ai
}

module "cognitive_service" {
  source                                 = "./modules/cognitive_service"
  location                               = var.search_service_location != "" ? var.search_service_location : var.location # must be in the same location as search service
  tags                                   = local.tags
  resource_group_name                    = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id             = var.log_analytics_workspace_id
  cognitive_service_name                 = var.cognitive_service_name != "" ? var.cognitive_service_name : "${local.abbrs.cognitiveServicesAccounts}${local.resourceToken}"
  cognitive_service_kind                 = "CognitiveServices"
  cognitive_service_sku                  = var.cognitive_service_sku
  local_auth_enabled                     = false
  connectivity_delay_in_seconds          = var.connectivity_delay_in_seconds
  vnet_location                          = data.azurerm_virtual_network.virtual_network.location
  subnet_id                              = azapi_resource.subnet_private_endpoints.id
  public_network_access_enabled          = false
  outbound_network_access_restricted     = true
  private_dns_zone_id_cognitive_services = var.private_dns_zone_id_cognitive_services
}

module "document_intelligence" {
  source                                 = "./modules/cognitive_service"
  location                               = var.form_recognizer_service_location != "" ? var.form_recognizer_service_location : var.location
  tags                                   = local.tags
  resource_group_name                    = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id             = var.log_analytics_workspace_id
  cognitive_service_name                 = var.form_recognizer_name != "" ? var.form_recognizer_name : "${local.abbrs.cognitiveServicesFormRecognizer}${local.resourceToken}"
  cognitive_service_kind                 = "FormRecognizer"
  cognitive_service_sku                  = var.form_recognizer_sku
  local_auth_enabled                     = false
  connectivity_delay_in_seconds          = var.connectivity_delay_in_seconds
  vnet_location                          = data.azurerm_virtual_network.virtual_network.location
  subnet_id                              = azapi_resource.subnet_private_endpoints.id
  public_network_access_enabled          = false
  outbound_network_access_restricted     = false
  private_dns_zone_id_cognitive_services = var.private_dns_zone_id_cognitive_services
}

module "computer_vision" {
  source                                 = "./modules/cognitive_service"
  location                               = var.computer_vision_service_location != "" ? var.computer_vision_service_location : var.location
  tags                                   = local.tags
  resource_group_name                    = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id             = var.log_analytics_workspace_id
  cognitive_service_name                 = var.computer_vision_name != "" ? var.computer_vision_name : "${local.abbrs.cognitiveServicesComputerVision}${local.resourceToken}"
  cognitive_service_kind                 = "ComputerVision"
  cognitive_service_sku                  = var.computer_vision_sku
  local_auth_enabled                     = false
  connectivity_delay_in_seconds          = var.connectivity_delay_in_seconds
  vnet_location                          = data.azurerm_virtual_network.virtual_network.location
  subnet_id                              = azapi_resource.subnet_private_endpoints.id
  public_network_access_enabled          = false
  outbound_network_access_restricted     = true
  private_dns_zone_id_cognitive_services = var.private_dns_zone_id_cognitive_services
}
