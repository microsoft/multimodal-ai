output "cognitive_account_id" {
  description = "The ID of the cognitive service account."
  value       = azurerm_cognitive_account.cognitive_service.id
}

output "cognitive_account_endpoint" {
  description = "The base URL of the cognitive service account."
  value       = azurerm_cognitive_account.cognitive_service.endpoint
}

output "cognitive_services_key" {
  description = "Cognitive services key."
  value       = azurerm_cognitive_account.cognitive_service.primary_access_key
}

output "cognitive_services_name" {
  description = "Cognitive services name."
  value       = azurerm_cognitive_account.cognitive_service.name
}

output "cognitive_services_principal_id" {
  description = "Specifies the principal id of the function."
  sensitive   = false
  value       = azurerm_cognitive_account.cognitive_service.identity[0].principal_id
}
