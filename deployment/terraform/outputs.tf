# Output variables for reference
output "location" {
  value = var.location
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}
