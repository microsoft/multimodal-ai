output "cognitive_account_id" {
  description = "The ID of the cognitive service account."
  value       = azurerm_cognitive_account.cognitive_service.id
}

output "cognitive_account_endpoint" {
  description = "The base URL of the cognitive service account."
  value       = azurerm_cognitive_account.cognitive_service.endpoint
}

output "azurerm_cognitive_account_service_id" {
  description = "The ID of the cognitive service account."
  value       = azurerm_cognitive_account.cognitive_service.id
}

output "azurerm_cognitive_account_endpoint" {
  description = "The base URL of the cognitive service account."
  value       = azurerm_cognitive_account.cognitive_service.endpoint
}


output "cognitive_services_key" {
  description = "Cognitive services key."
  value       = azurerm_cognitive_account.cognitive_service.primary_access_key
}
