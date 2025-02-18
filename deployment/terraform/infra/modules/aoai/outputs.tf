output "cognitive_account_id" {
  description = "The ID of the cognitive service account."
  value       = azurerm_cognitive_account.aoai.id
}

output "cognitive_account_endpoint" {
  description = "The base URL of the cognitive service account."
  value       = azurerm_cognitive_account.aoai.endpoint
}

output "cognitive_account_name" {
  description = "The name of the cognitive service account."
  value       = azurerm_cognitive_account.aoai.name
}
