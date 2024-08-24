module "appserviceplan" {
  source = "./modules/appserviceplan"

  resource_group_name = azurerm_resource_group.mmai.name
  location            = local.location
  tags                = var.tags
  appservice_name     = local.app_service_frontend_name
  appservice_sku      = local.app_service_sku

}
