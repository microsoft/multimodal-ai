locals {
  function_application_settings_default = {
    AzureWebJobsSecretStorageType        = "keyvault"
    AzureWebJobsSecretStorageKeyVaultUri = data.azurerm_key_vault.key_vault.vault_uri
  }
  function_application_settings = merge(local.function_application_settings_default, var.function_application_settings)

  storage_account = {
    resource_group_name = split("/", var.function_storage_account_id)[4]
    name                = split("/", var.function_storage_account_id)[8]
  }

  key_vault = {
    resource_group_name = split("/", var.function_key_vault_id)[4]
    name                = split("/", var.function_key_vault_id)[8]
  }
}
