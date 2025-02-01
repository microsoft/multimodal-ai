module "ampls" {
  source = "./modules/ampls"

  ampls_name          = "${local.prefix}-ampls001"
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.resource_group.name
}
