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
    null_resource.create_indexer,
    azapi_update_resource.blob_azure_search_private_endpoint_approver,
    azapi_update_resource.open_ai_azure_search_private_endpoint_approver,
    azapi_update_resource.computer_vision_azure_search_private_endpoint_approver,
    azapi_update_resource.ai_multi-service_azure_search_private_endpoint_approver,
//    azapi_update_resource.form_recognition_azure_search_private_endpoint_approver,
    azapi_update_resource.function_azure_search_private_endpoint_approver
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
}

resource "azurerm_search_shared_private_link_service" "shared_private_link_search_service_aoai" {
  depends_on         = [
    null_resource.create_datasource,
    null_resource.create_index,
    null_resource.create_skillset,
    null_resource.create_indexer,
    ] # race / conflict conditions if too many updates are happening to AI Search
  name               = "${var.search_service_name}-spa-aoai"
  search_service_id  = azurerm_search_service.search_service.id
  subresource_name   = "openai_account"
  target_resource_id = var.openai_account_id
  request_message    = "Auto-Approved"
}

resource "azurerm_search_shared_private_link_service" "shared_private_link_search_service_blob" {
  # Looks like only one private link can be created at a time. So, we need to process them sequentially.
  # Otherwise we may get 409 Conflict error.
  depends_on         = [azurerm_search_shared_private_link_service.shared_private_link_search_service_aoai] # can only add one at a time
  name               = "${var.search_service_name}-spa-blob"
  search_service_id  = azurerm_search_service.search_service.id
  subresource_name   = "blob"
  target_resource_id = var.storage_account_id
  request_message    = "Auto-Approved"
}

resource "azurerm_search_shared_private_link_service" "shared_private_link_ai_vision" {
  depends_on         = [azurerm_search_shared_private_link_service.shared_private_link_search_service_blob] # can only add one at a time
  name               = "${var.search_service_name}-spa-cog-cv"
  search_service_id  = azurerm_search_service.search_service.id
  subresource_name   = "cognitiveservices_account"
  target_resource_id = var.vision_id
  request_message    = "Auto-Approved"
}

/*resource "azurerm_search_shared_private_link_service" "shared_private_link_form_recognition" {
  depends_on         = [azurerm_search_shared_private_link_service.shared_private_link_ai_vision] # can only add one at a time
  name               = "${var.search_service_name}-spa-cog-fr"
  search_service_id  = azurerm_search_service.search_service.id
  subresource_name   = "cognitiveservices_account"
  target_resource_id = var.form_recognizer_id
  request_message    = "Auto-Approved"
}*/

resource "azurerm_search_shared_private_link_service" "shared_private_link_ai_multi-service" {
  depends_on         = [azurerm_search_shared_private_link_service.shared_private_link_form_recognition] # can only add one at a time
  name               = "${var.search_service_name}-spa-cog-multi"
  search_service_id  = azurerm_search_service.search_service.id
  subresource_name   = "cognitiveservices_account"
  target_resource_id = var.cognitive_account_id
  request_message    = "Auto-Approved"
}

resource "azurerm_search_shared_private_link_service" "shared_private_link_function" {
  depends_on         = [azurerm_search_shared_private_link_service.shared_private_link_ai_multi-service] # can only add one at a time
  name               = "${var.search_service_name}-spa-func"
  search_service_id  = azurerm_search_service.search_service.id
  subresource_name   = "sites"
  target_resource_id = var.function_id
  request_message    = "Auto-Approved"
}

resource "azapi_update_resource" "function_azure_search_private_endpoint_approver" {
  depends_on = [
    azurerm_search_shared_private_link_service.shared_private_link_function
  ]
  type        = "Microsoft.Web/sites/privateEndpointConnections@2024-04-01"
  resource_id = local.function_pe_connection_id
  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Auto-Approved"
      }
    }
  }
}

resource "azapi_update_resource" "computer_vision_azure_search_private_endpoint_approver" {
  depends_on = [
    azurerm_search_shared_private_link_service.shared_private_link_ai_vision
  ]
  type        = "Microsoft.CognitiveServices/accounts/privateEndpointConnections@2024-10-01"
  resource_id = local.vision_pe_connection_id
  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Auto-Approved"
      }
    }
  }
}

/*resource "azapi_update_resource" "form_recognition_azure_search_private_endpoint_approver" {
  depends_on = [
    azurerm_search_shared_private_link_service.shared_private_link_form_recognition
  ]
  type        = "Microsoft.CognitiveServices/accounts/privateEndpointConnections@2024-10-01"
  resource_id = local.form_recognizer_pe_connection_id
  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Auto-Approved"
      }
    }
  }
}*/

resource "azapi_update_resource" "ai_multi-service_azure_search_private_endpoint_approver" {
  depends_on = [
    azurerm_search_shared_private_link_service.shared_private_link_ai_multi-service
  ]
  type        = "Microsoft.CognitiveServices/accounts/privateEndpointConnections@2024-10-01"
  resource_id = local.ai_multi_account_pe_connection_id
  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Auto-Approved"
      }
    }
  }
}

resource "azapi_update_resource" "open_ai_azure_search_private_endpoint_approver" {
  depends_on = [
    azurerm_search_shared_private_link_service.shared_private_link_search_service_aoai
  ]
  type        = "Microsoft.CognitiveServices/accounts/privateEndpointConnections@2024-10-01"
  resource_id = local.openai_pe_connection_id
  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Auto-Approved"
      }
    }
  }
}

resource "azapi_update_resource" "blob_azure_search_private_endpoint_approver" {
  depends_on = [
    azurerm_search_shared_private_link_service.shared_private_link_search_service_blob
  ]
  type        = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2024-01-01"
  resource_id = local.blob_pe_connection_id
  body = {
    properties = {
      privateLinkServiceConnectionState = {
        status      = "Approved"
        description = "Auto-Approved"
      }
    }
  }

  # This is needed as this PUT operation (https://learn.microsoft.com/rest/api/storagerp/private-endpoint-connections/put?view=rest-storagerp-2023-05-01&tabs=HTTP)
  # on the Storage Account is not idempotent and throws a 400 error when resubmitting.
  # BUG: https://github.com/Azure/azure-rest-api-specs/issues/30308
  lifecycle {
    ignore_changes = [
      resource_id,
      body
    ]
  }
}

resource "time_sleep" "sleep_connectivity" {
  create_duration = "${var.connectivity_delay_in_seconds}s"

  depends_on = [
    azurerm_private_endpoint.private_endpoint_search_service
  ]
}
