

resource "azurerm_private_endpoint" "function_private_endpoint" {
  name                = "${var.function_name}-pe"
  location            = var.vnet_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_subnet_id

  custom_network_interface_name = "function_private_endpoint_nic"
  private_dns_zone_group {
    name                 = "${var.function_name}-arecord"
    private_dns_zone_ids = [var.private_dns_zone_id_sites]
  }

  private_service_connection {
    name                           = "${var.function_name}-svc"
    private_connection_resource_id = azurerm_linux_function_app.linux_function_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "functionapp_subnet_connection" {
  app_service_id = azurerm_linux_function_app.linux_function_app.id
  subnet_id      = var.integration_subnet_id
}
