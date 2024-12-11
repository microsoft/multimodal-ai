
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_subnet_connection" {
  app_service_id = azurerm_linux_web_app.linux_webapp.id
  subnet_id      = var.subnet_id
}
