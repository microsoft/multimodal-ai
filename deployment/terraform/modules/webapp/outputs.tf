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

output "server_app_password" {
  sensitive = true
  value     = local.server_app_password
}

output "server_app_secret_name" {
  sensitive = false
  value     = local.server_app_secret_name
}

output "server_app_id" {
  value = local.server_app_id
}

output "server_app_name" {
  value = local.server_app_name
}

output "server_app_object_id" {
  value = local.server_app_object_id
}

output "client_app_secret_name" {
  sensitive = false
  value     = local.client_app_secret_name
}

output "client_app_password" {
  sensitive = true
  value     = local.client_app_password
}

output "client_app_id" {
  value = local.client_app_id
}

output "client_app_name" {
  value = local.client_app_name
}

output "client_app_object_id" {
  value = local.client_app_object_id
}
