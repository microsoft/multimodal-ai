resource "azurerm_role_assignment" "search_service_contributor" {
  scope                = azurerm_search_service.search_service.id
  role_definition_name = "Search Service Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "search_index_data_contributor" {
  scope                = azurerm_search_service.search_service.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "storage_blob_data_to_search_service" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_search_service.search_service.identity[0].principal_id
}

resource "azurerm_role_assignment" "knowledgestore_blob_data_to_search_service" {
  scope                = var.knowledgestore_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_search_service.search_service.identity[0].principal_id
}
