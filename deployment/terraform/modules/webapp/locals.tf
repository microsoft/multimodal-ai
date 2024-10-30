locals {
  webapp_application_settings_keyvault = {
    AzureWebJobsSecretStorageType        = "keyvault"
    AzureWebJobsSecretStorageKeyVaultUri = data.azurerm_key_vault.key_vault.vault_uri

  }

  webapp_aplication_settings_appinsights = {
    APPLICATIONINSIGHTS_CONNECTION_STRING           = var.webapp_application_insights_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY                  = var.webapp_application_insights_instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "~2"
    SnapshotDebugger_EXTENSION_VERSION              = "1.0.15"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
  }

  webapp_application_settings = merge(
    var.webapp_application_settings,
    var.webapp_key_vault_id != "" ? local.webapp_application_settings_keyvault : {},
    var.webapp_application_insights_connection_string != "" ? local.webapp_aplication_settings_appinsights : {},
    {
      AZURE_SERVER_APP_ID = length(azuread_application.server_app) > 0 ? azuread_application.server_app[0].client_id : var.server_app_id,
      AZURE_CLIENT_APP_ID = length(azuread_application.client_app) > 0 ? azuread_application.client_app[0].client_id : var.client_app_id
    }
  )

  key_vault = {
    resource_group_name = split("/", var.webapp_key_vault_id)[4]
    name                = split("/", var.webapp_key_vault_id)[8]
  }

  server_app_display_name = "mmai-serverapp-${var.resource_token}"
  server_app_secret_name  = "serverapp-secret-${var.resource_token}"
  client_app_display_name = "mmai-clientapp-${var.resource_token}"
  client_app_secret_name  = "clientapp-secret-${var.resource_token}"

  server_app_password  = length(azuread_application.server_app) > 0 ? tolist(azuread_application.server_app[0].password)[0].value : ""
  server_app_id        = length(azuread_application.server_app) > 0 ? azuread_application.server_app[0].client_id : var.server_app_id
  server_app_name      = length(azuread_application.server_app) > 0 ? azuread_application.server_app[0].display_name : ""
  server_app_object_id = length(azuread_application.server_app) > 0 ? azuread_application.server_app[0].object_id : ""
  client_app_password  = length(azuread_application.client_app) > 0 ? tolist(azuread_application.client_app[0].password)[0].value : ""
  client_app_id        = length(azuread_application.client_app) > 0 ? azuread_application.client_app[0].client_id : var.client_app_id
  client_app_name      = length(azuread_application.client_app) > 0 ? azuread_application.client_app[0].display_name : ""
  client_app_object_id = length(azuread_application.client_app) > 0 ? azuread_application.client_app[0].object_id : ""

  permission_scope_id = random_uuid.permission_scope_id.result
}

resource "random_uuid" "permission_scope_id" {
}
