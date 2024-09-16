resource "azurerm_role_assignment" "function_rolesassignment_storage_blob_data_owner" {
  scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_rolesassignment_key_vault_administrator" {
  scope                = var.function_key_vault_id #data.azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
}
