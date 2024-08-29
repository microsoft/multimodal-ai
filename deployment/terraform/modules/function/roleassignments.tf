resource "azurerm_role_assignment" "function_rolesassignment_storage_blob_data_owner" {
  scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
}

# resource "azurerm_role_assignment" "function_rolesassignment_storage_file_data_privileged_contributor" {
#   scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Storage File Data Privileged Contributor"
#   principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
# }

# resource "azurerm_role_assignment" "function_rolesassignment_storage_queue_data_contributor" {
#   scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Storage Queue Data Contributor"
#   principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
# }

# resource "azurerm_role_assignment" "function_rolesassignment_storage_table_data_contributor" {
#   scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Storage Table Data Contributor"
#   principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
# }

resource "azurerm_role_assignment" "function_rolesassignment_key_vault_administrator" {
  scope                = var.function_key_vault_id #data.azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
}



# // https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-reader
# // allows for blobServices/generateUserDelegationKey and blobs/read
# resource "azurerm_role_assignment" "functionToStorage1" {
#   scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
# }

# // https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-account-key-operator-service-role
# // allows for listkeys/action and regeneratekey/action
# resource "azurerm_role_assignment" "functionToStorage2" {
#   scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Storage Account Key Operator Service Role"
#   principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
# }

# // https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#reader-and-data-access
# // allows for storageAccounts/read
# resource "azurerm_role_assignment" "functionToStorage3" {
#   scope                = var.function_storage_account_id #data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Reader and Data Access"
#   principal_id         = azurerm_linux_function_app.linux_function_app.identity[0].principal_id
# }