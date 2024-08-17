module "ai_vision" {
    source = "./modules/cognitiveservices"

    location = local.location
    resource_group_name = azurerm_resource_group.mmai.name
    tags = var.tags

    cognitive_service_kind = local.coputer_vision_kind
    cognitive_service_name = local.computer_vision_name
    cognitive_service_sku = local.coputer_vision_sku

    user_assigned_identity_id = azurerm_user_assigned_identity.user_assigned_identity.id
    subnet_id = null
    customer_managed_key = null
    log_analytics_workspace_id = module.azure_log_analytics.log_analytics_id
}