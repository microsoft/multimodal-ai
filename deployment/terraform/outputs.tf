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

output "skills_function_ad_appregistration_client_id" {
  value = module.skills.function_ad_app_client_id
}

locals {
  rg_delete_command    = "az group delete --name ${azurerm_resource_group.resource_group.name}"
  adapp_delete_command = "\naz ad app delete --id ${module.skills.function_ad_app_client_id}"

}

output "cleanup_command" {
  value = "${local.rg_delete_command}${var.function_ad_app_client_id == "" ? local.adapp_delete_command : ""}"
}
