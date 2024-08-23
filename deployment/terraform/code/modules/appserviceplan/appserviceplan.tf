resource "azurerm_service_plan" "service_plan" {
  name                = "${var.appservice_name}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.appservice_sku
}
