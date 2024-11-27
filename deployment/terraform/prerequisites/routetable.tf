resource "azurerm_route_table" "route_table" {
  name                = "${local.abbrs.networkRouteTables}${local.prefix}-rt001"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  tags                = var.tags

  bgp_route_propagation_enabled = true
  route                         = []
}
