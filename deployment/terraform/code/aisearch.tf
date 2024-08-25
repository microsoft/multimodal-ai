module "ai_search" {
  source = "./modules/aisearch"

  location            = local.location
  resource_group_name = azurerm_resource_group.mmai.name
  tags                = var.tags

  search_service_name            = local.ai_search_name
  search_service_sku             = local.ai_search_sku
  search_service_partition_count = 1
  search_service_replica_count   = 1
  customer_managed_key           = null
  log_analytics_workspace_id     = module.azure_log_analytics.log_analytics_id
  user_assigned_identity_id      = module.user_assigned_identity.user_assigned_identity_id
  subnet_id                      = null
}

resource "azurerm_role_assignment" "aisearch_openai_contributor" {
  scope                = module.openai.azurerm_cognitive_account_service_id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = module.ai_search.search_service_identity_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "aisearch_openai_user" {
  scope                = module.openai.azurerm_cognitive_account_service_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.ai_search.search_service_identity_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "aisearch_storage_blob_contirbutor" {
  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.ai_search.search_service_identity_id
  principal_type       = "ServicePrincipal"
}