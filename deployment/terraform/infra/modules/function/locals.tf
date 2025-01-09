locals {
  function_application_settings_keyvault = {
    AzureWebJobsSecretStorageType        = "keyvault"
    AzureWebJobsSecretStorageKeyVaultUri = data.azurerm_key_vault.key_vault.vault_uri
  }

  function_application_settings = merge(
    var.function_application_settings,
  var.function_key_vault_id != "" ? local.function_application_settings_keyvault : {})

  storage_account = {
    resource_group_name = split("/", var.function_storage_account_id)[4]
    name                = split("/", var.function_storage_account_id)[8]
  }

  key_vault = {
    resource_group_name = split("/", var.function_key_vault_id)[4]
    name                = split("/", var.function_key_vault_id)[8]
  }

  skills_function_appregistration_client_id = var.skills_function_appregistration_client_id != "" ? var.skills_function_appregistration_client_id : azuread_application.function_ad_app[0].client_id

}
