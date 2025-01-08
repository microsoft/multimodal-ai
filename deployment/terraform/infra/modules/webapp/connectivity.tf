resource "azurerm_private_endpoint" "function_private_endpoint" {
  name                = "webapp_private_endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_subnet_id

  custom_network_interface_name = "webapp_private_endpoint_nic"
  private_dns_zone_group {
    name                 = "private_dns_zone_group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.private_dns_zone_sites.id]
  }

  private_service_connection {
    name                           = "webapp_private_endpoint_connection"
    private_connection_resource_id = azurerm_linux_web_app.linux_webapp.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "webapp_subnet_connection" {
  app_service_id = azurerm_linux_web_app.linux_webapp.id
  subnet_id      = var.integration_subnet_id
}
