module "loganalytics" {
  source = "./modules/loganalytics"

  location                     = var.location
  tags                         = local.tags
  resource_group_name          = azurerm_resource_group.resource_group.name
  log_analytics_workspace_name = var.log_analytics_workspace_name != "" ? var.log_analytics_workspace_name : "${local.abbrs.operationalInsightsWorkspaces}${local.resourceToken}"
}

module "applicationinsights" {
  source = "./modules/applicationinsights"

  location                     = var.location
  tags                         = local.tags
  resource_group_name          = azurerm_resource_group.resource_group.name
  application_insights_name    = var.application_insights_name != "" ? var.application_insights_name : "${local.abbrs.insightsComponents}${local.resourceToken}"
  log_analytics_workspace_id   = module.loganalytics.log_analytics_id
}

module "keyvault" {
  source = "./modules/keyvault"
  location                     = var.location
  tags                         = local.tags
  resource_group_name          = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id   = module.loganalytics.log_analytics_id
  key_vault_name                = var.key_vault_name != "" ? var.key_vault_name : "${local.abbrs.keyVaultVaults}${local.resourceToken}"
  key_vault_sku_name            = var.key_vault_sku_name
#   cmk_uai_id                    = module.user_assigned_identity.user_assigned_identity_id
#   subnet_id                     = module.network.subnet_private_endpoints_id
#   private_dns_zone_id_key_vault = module.network.private_dns_zone_key_vault_id
}

module "storage" {
  source = "./modules/storage"
  location                 = var.location
  tags                     = local.tags
  resource_group_name      = azurerm_resource_group.resource_group.name
  storage_account_name     = var.storage_account_name  != "" ? var.storage_account_name : substr("${local.abbrs.storageStorageAccounts}${local.resourceToken}",0,24)  
  storage_account_container_names  = [var.storage_container_name_content]
  # storage_account_share_names      = [var.storage_share_name_function_app]
  log_analytics_workspace_id   = module.loganalytics.log_analytics_id
#   subnet_id                = module.network.subnet_private_endpoints_id
#   cmk_uai_id               = module.user_assigned_identity.user_assigned_identity_id
#   cmk_key_vault_id         = module.key_vault.key_vault_id
#   cmk_key_name             = module.key_vault.key_vault_cmk_name
#   private_dns_zone_id_blob = module.network.private_dns_zone_blob_id
}


module "backend_functionapp" {
  source = "./modules/function"
  location                 = var.location
  tags                     = local.tags
  resource_group_name      = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id   = module.loganalytics.log_analytics_id
  function_name = var.backend_service_name != "" ? var.backend_service_name : "backend-${local.resourceToken}"  
  function_sku = var.appservice_plan_sku
  function_application_insights_connection_string=module.applicationinsights.application_insights_connection_string
  function_application_insights_instrumentation_key=module.applicationinsights.application_insights_instrumentation_key
  function_key_vault_id=module.keyvault.key_vault_id
  function_code_path = var.backend_service_code_path
  function_storage_account_id = module.storage.storage_account_id
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