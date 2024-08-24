data "archive_file" "frontend" {
  type        = "zip"
  source_dir  = "../../../azure-search-openai-demo/app/frontend/" # Replace with the path to your application code
  output_path = "${path.module}/${format("appservice_frontend-%s.zip", formatdate("YYYY-MM-DD'-'hh_mm_ss", timestamp()))}"
}

resource "azurerm_linux_web_app" "web_app_frontend" {
  name                = local.app_service_frontend_name
  location            = var.location
  resource_group_name = azurerm_resource_group.mmai.name
  service_plan_id     = module.appserviceplan.azurerm_service_plan_id

  public_network_access_enabled = true

  site_config {
    always_on                = true
    remote_debugging_enabled = true
    application_stack {
      node_version = "18-lts"
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      module.user_assigned_identity.user_assigned_identity_id
    ]
  }

  auth_settings {
    enabled = false
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE       = "0"
    SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
  }
}

resource "null_resource" "web_app_deployment_frontned" {

  depends_on = [azurerm_linux_web_app.web_app_frontend]

  triggers = {
    file = data.archive_file.frontend.output_base64sha256
  }

  provisioner "local-exec" {
    command = "az webapp deployment source config-zip --resource-group ${azurerm_resource_group.mmai.name} --name ${local.app_service_frontend_name} --src ${data.archive_file.frontend.output_path}"
  }
}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories_linux_function_app_frontend" {
  resource_id = azurerm_linux_web_app.web_app_frontend.id
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting_linux_function_app_frontend" {
  name                       = "logAnalytics"
  target_resource_id         = azurerm_linux_web_app.web_app_frontend.id
  log_analytics_workspace_id = module.azure_log_analytics.log_analytics_id

  dynamic "enabled_log" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories_linux_function_app_frontend.log_category_groups
    content {
      category_group = entry.value
    }
  }

  dynamic "metric" {
    iterator = entry
    for_each = data.azurerm_monitor_diagnostic_categories.diagnostic_categories_linux_function_app_frontend.metrics
    content {
      category = entry.value
      enabled  = true
    }
  }
}
