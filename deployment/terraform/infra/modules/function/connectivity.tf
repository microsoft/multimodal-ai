locals {
  private_dns_zone_sites = {
    resource_group_name = split("/", var.private_dns_zone_id_sites)[4]
    name                = split("/", var.private_dns_zone_id_sites)[8]
  }
}

data "azurerm_private_dns_zone" "private_dns_zone_sites" {
  name                = local.private_dns_zone_sites.name
  resource_group_name = local.private_dns_zone_sites.resource_group_name
}

resource "azurerm_private_endpoint" "function_private_endpoint" {
  name                = "function_private_endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  custom_network_interface_name = "function_private_endpoint_nic"
  private_dns_zone_group {
    name                 = "private_dns_zone_group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.private_dns_zone_sites.id]
  }

  private_service_connection {
    name                           = "function_private_endpoint_connection"
    private_connection_resource_id = azurerm_linux_function_app.linux_function_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
