resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting_linux_function_app" {
  name                       = "logAnalytics"
  target_resource_id         = azurerm_linux_web_app.linux_webapp.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories_linux_webapp.log_category_groups
    content {
      category_group = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories_linux_webapp.metrics
    content {
      category = entry.value
      enabled  = true
    }
  }
}
