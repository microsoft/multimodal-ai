resource "azuread_application" "function_ad_app" {
  count = var.skills_function_appregistration_client_id != "" ? 0 : 1

  display_name = "mmai-functionapp-${var.function_name}"
  owners       = [data.azurerm_client_config.current.object_id]
}
