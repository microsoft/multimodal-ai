resource "azurerm_private_endpoint" "private_endpoint_ampls" {
  name                = "${var.ampls_name}-pe"
  location            = var.vnet_location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  custom_network_interface_name = "${var.ampls_name}-nic"
  private_service_connection {
    name                           = "${var.ampls_name}-pe"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_monitor_private_link_scope.ampls.id
    subresource_names              = ["azuremonitor"]
  }
  subnet_id = var.subnet_id

  private_dns_zone_group {
    name                 = "${var.ampls_name}-arecord"
    private_dns_zone_ids = var.private_dns_zone_list_ampls
  }

}

resource "time_sleep" "sleep_connectivity" {
  create_duration = "${var.connectivity_delay_in_seconds}s"

  depends_on = [
    azurerm_private_endpoint.private_endpoint_ampls
  ]

}
