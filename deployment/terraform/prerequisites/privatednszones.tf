resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each = local.private_dns_zone_names

  name                = each.value
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_links" {
  for_each = local.private_dns_zone_names

  name                = "${each.key}-${azurerm_virtual_network.virtual_network.name}"
  resource_group_name = azurerm_private_dns_zone.private_dns_zone[each.key].resource_group_name
  tags                = var.tags

  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
}
