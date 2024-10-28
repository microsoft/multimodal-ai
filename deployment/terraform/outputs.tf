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

output "skills_function_appregistration_client_id" {
  value = module.skills.skills_function_appregistration_client_id
}

output "webapp_client_appregistration_client_id" {
  value = nonsensitive(sensitive(module.backend_webapp.client_app_id))
}

output "webapp_server_appregistration_client_id" {
  value = nonsensitive(sensitive(module.backend_webapp.server_app_id))
}

locals {
  rg_delete_command                  = "az group delete --name ${azurerm_resource_group.resource_group.name}"
  adapp_delete_command_function      = var.skills_function_appregistration_client_id == "" ? "\naz ad app delete --id ${module.skills.skills_function_appregistration_client_id}" : ""
  adapp_delete_command_webapp_client = var.webapp_auth_settings.enable_auth && var.webapp_auth_settings.client_app.app_id == "" ? "\naz ad app delete --id ${module.backend_webapp.client_app_id}" : ""
  adapp_delete_command_webapp_server = var.webapp_auth_settings.enable_auth && var.webapp_auth_settings.server_app.app_id == "" ? "\naz ad app delete --id ${module.backend_webapp.server_app_id}" : ""
}

output "cleanup_command" {
  value = "${local.rg_delete_command}${local.adapp_delete_command_function}${local.adapp_delete_command_webapp_client}${local.adapp_delete_command_webapp_server}"
}
