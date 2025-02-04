resource "azurerm_resource_group" "resource_group_container_app" {
  name     = "${local.prefix}-container-rg"
  location = var.location
  tags     = var.tags
}
