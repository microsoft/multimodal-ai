output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}

output "multimodel_ai_web_site" {
  value = "https://${module.backend_webapp.linux_webapp_default_hostname}"
}

output "documents_source_storage" {
  value = module.storage.storage_account_name
}

output "documents_source_container" {
  value = var.storage_container_name_content
}
