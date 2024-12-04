resource "azurerm_virtual_network" "virtual_network" {
  name                = "${local.abbrs.virtualNetworks}${local.prefix}-vnet001"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  tags                = var.tags

  address_space = [
    var.virtual_network_address_space
  ]
}
