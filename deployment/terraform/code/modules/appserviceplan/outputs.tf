output "azurerm_service_plan_id" {
  description = "Specifies the resource id of the service plan."
  sensitive   = false
  value       = azurerm_service_plan.service_plan.id
}