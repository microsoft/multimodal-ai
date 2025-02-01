output "azure_monitor_private_link_scope_resource_id" {
  value       = azurerm_monitor_private_link_scope.ampls.id
  description = "Specifies the resource ID of the Azure Monitor Private Link Scope."
  sensitive   = false
}
