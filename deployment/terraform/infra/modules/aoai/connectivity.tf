resource "azurerm_private_endpoint" "private_endpoint_open_ai" {
  name                = "${var.cognitive_service_name}-pe"
  location            = var.vnet_location
  resource_group_name = var.resource_group_name

  custom_network_interface_name = "${var.cognitive_service_name}-nic"
  private_service_connection {
    name                           = "${var.cognitive_service_name}-pe"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.aoai.id
    subresource_names              = ["account"]
  }
  subnet_id = var.subnet_id
  private_dns_zone_group {
    name                 = "${var.cognitive_service_name}-arecord"
    private_dns_zone_ids = [var.private_dns_zone_id_open_ai]
  }
}

resource "time_sleep" "sleep_connectivity" {
  create_duration = "${var.connectivity_delay_in_seconds}s"

  depends_on = [
    azurerm_private_endpoint.private_endpoint_open_ai
  ]
}
