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
  location            = var.vnet_location
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

resource "azurerm_search_shared_private_link_service" "shared_private_link_search_service_aoai" {
  name                = "${var.search_service_name}-spa-aoai"
  search_service_id   = azurerm_search_service.search_service.id
  subresource_name    = "openai_account"
  target_resource_id  = var.openai_account_id  
  request_message     = "Auto approved"
  depends_on = [ null_resource.ai_search_disable_public_network_access ]
}

resource "azurerm_search_shared_private_link_service" "shared_private_link_search_service_storage" {
  name                = "${var.search_service_name}-spa-strg"
  search_service_id   = azurerm_search_service.search_service.id
  subresource_name    = "blob"
  target_resource_id  = var.storage_account_id
  request_message     = "Auto approved"
  depends_on = [ null_resource.ai_search_disable_public_network_access ]
}

resource "null_resource" "ai_search_approve_shared_private_link" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<-EOT
      $aoai_id = $(az network private-endpoint-connection list --id ${var.openai_account_id} --query "[?contains(properties.privateEndpoint.id, 'vnet')].id" -o json) | ConvertFrom-Json
      $strg_id = $(az network private-endpoint-connection list --id ${var.storage_account_id} --query "[?contains(properties.privateEndpoint.id, 'vnet')].id" -o json) | ConvertFrom-Json
      az network private-endpoint-connection approve --id $aoai_id --description "Auto-Approved"
      az network private-endpoint-connection approve --id $strg_id --description "Auto-Approved"
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [ 
    azurerm_search_shared_private_link_service.shared_private_link_search_service_aoai,
    azurerm_search_shared_private_link_service.shared_private_link_search_service_storage 
    ]
}

resource "time_sleep" "sleep_connectivity" {
  create_duration = "${var.connectivity_delay_in_seconds}s"

  depends_on = [
    azurerm_private_endpoint.private_endpoint_search_service
  ]
}
