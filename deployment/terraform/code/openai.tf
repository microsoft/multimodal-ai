module "openai" {
  source = "./modules/cognitiveservices"

  location            = local.location
  resource_group_name = azurerm_resource_group.mmai.name
  tags                = var.tags

  cognitive_service_kind = local.opeanai_kind
  cognitive_service_name = local.opeanai_name
  cognitive_service_sku  = local.opeanai_sku

  model_deployment = {
    "${local.chat_deployment}" = jsonencode({ model = local.chat_model, capacity = local.chat_capacity, version = local.chat_version })
    "${local.embedding_deployment}" = jsonencode({ model = local.embedding_model, capacity = local.embedding_capacity, version = local.embedding_version})
  }

  subnet_id                  = null
  customer_managed_key       = null
  log_analytics_workspace_id = module.azure_log_analytics.log_analytics_id
}

resource "azurerm_role_assignment" "openai_storage_blob_contirbutor" {
  scope                = module.storage_account.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.openai.azurerm_cognitive_account_principal_id
  principal_type       = "ServicePrincipal"
}