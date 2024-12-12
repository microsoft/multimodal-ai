resource "null_resource" "ai_search_disable_public_network_access" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<-EOT
      az search service update --resource-group ${var.resource_group_name} --name ${var.search_service_name} --public-network-access ${var.public_network_access_enabled ? "enabled" : "disabled"}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    null_resource.create_datasource,
    null_resource.create_index,
    null_resource.create_skillset,
    null_resource.create_indexer
  ]
}

resource "azurerm_private_endpoint" "private_endpoint_search_service" {
  name                = "${var.search_service_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name

  custom_network_interface_name = "${var.search_service_name}-nic"
  private_service_connection {
    name                           = "${var.search_service_name}-pe"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_search_service.search_service.id
    subresource_names              = ["searchService"]
  }
  subnet_id = var.subnet_id

  private_dns_zone_group {
    name                 = "${var.search_service_name}-arecord"
    private_dns_zone_ids = [var.private_dns_zone_id_ai_search]
  }

  depends_on = [
    null_resource.ai_search_disable_public_network_access
  ]
}

resource "time_sleep" "sleep_connectivity" {
  create_duration = "${var.connectivity_delay_in_seconds}s"

  depends_on = [
    azurerm_private_endpoint.private_endpoint_search_service
  ]
}
