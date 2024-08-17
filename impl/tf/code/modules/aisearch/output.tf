output "search_service_id" {
  value       = azurerm_search_service.search_service.id
  description = "Specifies the resource id of the search service."
  sensitive   = false
}

output "search_service_name" {
  value       = azurerm_search_service.search_service.name
  description = "Specifies the resource name of the search service."
  sensitive   = false
}

output "search_service_key" {
  value       = azurerm_search_service.search_service.primary_key
  description = "Specifies the resource name of the search service."
  sensitive   = true
}

