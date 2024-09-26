output "linux_webapp_id" {
  description = "Specifies the resource id of the function."
  sensitive   = false
  value       = azurerm_linux_web_app.linux_webapp.id
}

output "linux_webapp_default_hostname" {
  description = "Specifies the endpoint of the function."
  sensitive   = false
  value       = azurerm_linux_web_app.linux_webapp.default_hostname
}

output "linux_webapp_principal_id" {
  description = "Specifies the principal id of the function."
  sensitive   = false
  value       = azurerm_linux_web_app.linux_webapp.identity[0].principal_id
}
