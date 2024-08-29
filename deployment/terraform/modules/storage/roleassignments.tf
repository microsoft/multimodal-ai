resource "azurerm_role_assignment" "current_role_assignment_storage_blob_data_owner" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

# resource "azurerm_role_assignment" "function_rolesassignment_storage_file_data_privileged_contributor" {
#   scope                = azurerm_storage_account.storage.id
#   role_definition_name = "Storage File Data Privileged Contributor"
#   principal_id         = data.azurerm_client_config.current.object_id
# }
