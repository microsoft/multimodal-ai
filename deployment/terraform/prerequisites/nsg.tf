resource "azurerm_network_security_group" "network_security_group" {
  name                = "${local.abbrs.networkNetworkSecurityGroups}${local.prefix}-nsg001"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  tags                = var.tags

  security_rule = []
}
