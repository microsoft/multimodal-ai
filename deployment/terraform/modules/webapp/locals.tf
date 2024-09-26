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
  var.webapp_application_insights_connection_string != "" ? local.webapp_aplication_settings_appinsights : {})

  key_vault = {
    resource_group_name = split("/", var.webapp_key_vault_id)[4]
    name                = split("/", var.webapp_key_vault_id)[8]
  }
}
