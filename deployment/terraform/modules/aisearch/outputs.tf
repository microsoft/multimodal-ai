output "search_service_identity" {
  description = "The system managed identity principalid of the search service account."
  value       = azurerm_search_service.search_service.identity[0].principal_id
}

output "search_service_resource_id" {
  description = "The ID of the search service ."
  value       = azurerm_search_service.search_service.id
}

output "search_service_name" {
  description = "The name of the search service."
  value       = azurerm_search_service.search_service.name
}

data "azuread_service_principal" "search_service_principal" {
  object_id = azurerm_search_service.search_service.identity[0].principal_id
}

output "managed_identity_application_id" {
  value = data.azuread_service_principal.search_service_principal.client_id
}


output "search_service_index_name" {
  value = var.search_service_index_name
}
output "search_service_indexer_name" {
  value = var.search_service_indexer_name
}
output "search_service_skillset_name" {
  value = var.search_service_skillset_name
}
output "search_service_datasource_name" {
  value = var.search_service_datasource_name
}
