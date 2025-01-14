data "azurerm_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories_linux_webapp" {
  resource_id = azurerm_linux_web_app.linux_webapp.id
}

data "azurerm_key_vault" "key_vault" {
  name                = local.key_vault.name
  resource_group_name = local.key_vault.resource_group_name
}

data "archive_file" "file_function" {
  count = var.webapp_code_path != "" ? 1 : 0

  type        = "zip"
  source_dir  = var.webapp_code_path
  output_path = "${path.module}/${format("webapp-${var.webapp_name}-%s.zip", formatdate("YYYY-MM-DD'-'hh_mm_ss", timestamp()))}"

  depends_on = [null_resource.linux_webapp_build]
}
