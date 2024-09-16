module "loganalytics" {
  source = "./modules/loganalytics"

  location                     = var.location
  tags                         = local.tags
  resource_group_name          = azurerm_resource_group.resource_group.name
  log_analytics_workspace_name = var.log_analytics_workspace_name != "" ? var.log_analytics_workspace_name : "${local.abbrs.operationalInsightsWorkspaces}${local.resourceToken}"
}

module "applicationinsights" {
  source = "./modules/applicationinsights"

  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  application_insights_name  = var.application_insights_name != "" ? var.application_insights_name : "${local.abbrs.insightsComponents}${local.resourceToken}"
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
}

module "keyvault" {
  source                     = "./modules/keyvault"
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  key_vault_name             = var.key_vault_name != "" ? var.key_vault_name : "${local.abbrs.keyVaultVaults}${local.resourceToken}"
  key_vault_sku_name         = var.key_vault_sku_name
  #   cmk_uai_id                    = module.user_assigned_identity.user_assigned_identity_id
  #   subnet_id                     = module.network.subnet_private_endpoints_id
  #   private_dns_zone_id_key_vault = module.network.private_dns_zone_key_vault_id
}

module "storage" {
  source                          = "./modules/storage"
  location                        = var.location
  tags                            = local.tags
  resource_group_name             = azurerm_resource_group.resource_group.name
  storage_account_name            = var.storage_account_name != "" ? var.storage_account_name : substr("${local.abbrs.storageStorageAccounts}${local.resourceToken}", 0, 24)
  storage_account_container_names = [var.storage_container_name_content, var.knowledgestore_storage_container_name]
  # storage_account_share_names      = [var.storage_share_name_function_app]
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  #   subnet_id                = module.network.subnet_private_endpoints_id
  #   cmk_uai_id               = module.user_assigned_identity.user_assigned_identity_id
  #   cmk_key_vault_id         = module.key_vault.key_vault_id
  #   cmk_key_name             = module.key_vault.key_vault_cmk_name
  #   private_dns_zone_id_blob = module.network.private_dns_zone_blob_id
}


module "backend_functionapp" {
  source                                            = "./modules/function"
  location                                          = var.location
  tags                                              = local.tags
  resource_group_name                               = azurerm_resource_group.resource_group.name
  subscription_id                                   = var.subscription_id
  log_analytics_workspace_id                        = module.loganalytics.log_analytics_id
  function_name                                     = var.backend_service_name != "" ? var.backend_service_name : "backend-${local.resourceToken}"
  function_sku                                      = var.appservice_plan_sku
  function_application_insights_connection_string   = module.applicationinsights.application_insights_connection_string
  function_application_insights_instrumentation_key = module.applicationinsights.application_insights_instrumentation_key
  function_key_vault_id                             = module.keyvault.key_vault_id
  function_code_path                                = var.backend_service_code_path
  function_storage_account_id                       = module.storage.storage_account_id
  # function_share_name = var.storage_share_name_function_app
  function_application_settings = {
    FUNCTIONS_WORKER_RUNTIME              = "python"
    WEBSITE_RUN_FROM_PACKAGE              = 1
    SCM_DO_BUILD_DURING_DEPLOYMENT        = true
    ENABLE_ORYX_BUILD                     = true
    ALLOWED_ORIGIN                        = ""
    APPLICATIONINSIGHTS_CONNECTION_STRING = module.applicationinsights.application_insights_connection_string
    PYTHONUNBUFFERED                      = "1"
    PYTHON_ENABLE_GUNICORN_MULTIWORKERS   = "true"
  }

}

module "aisearch" {
  source                                = "./modules/aisearch"
  location                              = var.location
  tags                                  = local.tags
  resource_group_name                   = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id            = module.loganalytics.log_analytics_id
  search_service_name                   = var.search_service_name != "" ? var.search_service_name : "${local.abbrs.searchServices}${local.resourceToken}"
  search_service_sku                    = var.search_service_sku
  search_service_partition_count        = var.search_service_partition_count
  search_service_replica_count          = var.search_service_replica_count
  storage_account_id                    = module.storage.storage_account_id
  storage_container_name_content        = var.storage_container_name_content
  search_service_datasource_name        = var.search_service_datasource_name != "" ? var.search_service_datasource_name : "${local.abbrs.searchServices}ds-${local.resourceToken}"
  search_service_index_name             = var.search_service_index_name != "" ? var.search_service_index_name : "${local.abbrs.searchServices}ind-${local.resourceToken}"
  search_service_indexer_name           = var.search_service_indexer_name != "" ? var.search_service_indexer_name : "${local.abbrs.searchServices}inder-${local.resourceToken}"
  search_service_skillset_name          = var.search_service_skillset_name != "" ? var.search_service_skillset_name : "${local.abbrs.searchServices}skl-${local.resourceToken}"
  azure_openai_endpoint                 = module.aoai.cognitive_account_endpoint
  azure_openai_text_deployment_id       = "text-embedding-ada-002"
  azure_openai_text_model_name          = "text-embedding-ada-002"
  cognitive_services_endpoint           = module.cognitive_service.cognitive_account_endpoint
  cognitive_services_key                = module.cognitive_service.cognitive_services_key
  pdf_merge_customskill_endpoint        = "https://${module.backend_functionapp.linux_function_app_default_hostname}/api/pdf_text_image_merge_skill"
  knowledgestore_storage_account_id     = module.storage.storage_account_id
  knowledgestore_storage_container_name = var.knowledgestore_storage_container_name
  depends_on                            = [module.backend_functionapp, module.aoai, module.cognitive_service, module.storage]
}

module "aoai" {
  source                     = "./modules/aoai"
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.openai_service_name != "" ? var.openai_service_name : "${local.abbrs.cognitiveServicesOpenAI}${local.resourceToken}"
  cognitive_service_kind     = "OpenAI"
  cognitive_service_sku      = var.openai_service_sku
  aoai_deployments           = var.aoai_deployments
}

module "cognitive_service" {
  source                     = "./modules/cognitive_service"
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.cognitive_service_name != "" ? var.cognitive_service_name : "${local.abbrs.cognitiveServicesAccounts}${local.resourceToken}"
  cognitive_service_kind     = "CognitiveServices"
  cognitive_service_sku      = var.cognitive_service_sku
  local_auth_enabled         = true
}

module "form_recognizer" {
  source                     = "./modules/cognitive_service"
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.form_recognizer_name != "" ? var.form_recognizer_name : "${local.abbrs.cognitiveServicesComputerVision}${local.resourceToken}"
  cognitive_service_kind     = "FormRecognizer"
  cognitive_service_sku      = var.form_recognizer_sku
}

module "computer_vision" {
  source                     = "./modules/cognitive_service"
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.computer_vision_name != "" ? var.computer_vision_name : "${local.abbrs.cognitiveServicesFormRecognizer}${local.resourceToken}"
  cognitive_service_kind     = "ComputerVision"
  cognitive_service_sku      = var.computer_vision_sku
}
