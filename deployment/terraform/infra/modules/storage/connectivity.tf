resource "azurerm_private_endpoint" "private_endpoint_storage_account" {
  for_each = var.private_endpoint_subresource_names

  name                = "${var.storage_account_name}-${each.value}-pe"
  location            = var.vnet_location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  custom_network_interface_name = "${var.storage_account_name}-${each.value}-nic"
  private_service_connection {
    name                           = "${var.storage_account_name}-${each.value}-svc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = [each.value]
  }
  subnet_id = var.subnet_id
  dynamic "private_dns_zone_group" {
    for_each = local.private_dns_zones_map[each.value] == "" ? [] : [1]
    content {
      name = "${var.storage_account_name}-arecord"
      private_dns_zone_ids = [
        local.private_dns_zones_map[each.value]
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      private_dns_zone_group
    ]
  }
}

resource "time_sleep" "sleep_connectivity" {
  create_duration = "${var.connectivity_delay_in_seconds}s"

  depends_on = [
    azurerm_private_endpoint.private_endpoint_storage_account
  ]
}
