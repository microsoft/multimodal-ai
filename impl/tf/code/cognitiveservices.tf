module "conginitiveservice" {
  source = "./modules/cognitiveservices"

  location            = local.location
  resource_group_name = azurerm_resource_group.mmai.name
  tags                = var.tags

  cognitive_service_kind = local.cognitiveservice_kind
  cognitive_service_name = local.cognitiveservice_name
  cognitive_service_sku  = local.cognitiveservice_sku

  user_assigned_identity_id  = module.user_assigned_identity.user_assigned_identity_id
  subnet_id                  = null
  customer_managed_key       = null
  log_analytics_workspace_id = module.azure_log_analytics.log_analytics_id
}