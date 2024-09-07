output "search_service_identity" {
  description = "The system managed identity principalid of the search service account."
  value       = azurerm_search_service.search_service.identity[0].principal_id
}

output "search_service_resource_id" {
  description = "The ID of the service account."
  value       = azurerm_search_service.search_service.id
}

