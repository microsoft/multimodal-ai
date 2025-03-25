resource "azurerm_linux_web_app" "linux_webapp" {
  name                = var.webapp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  identity {
    type         = var.webapp_user_assigned_identity_id != "" && var.webapp_user_assigned_identity_id != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = try(var.webapp_user_assigned_identity_id != "" && var.webapp_user_assigned_identity_id != null ? [var.webapp_user_assigned_identity_id] : [], [])
  }

  app_settings = local.webapp_application_settings

  dynamic "auth_settings_v2" {
    for_each = var.enable_auth ? [0] : []
    content {
      auth_enabled           = var.enable_auth
      unauthenticated_action = "RedirectToLoginPage"
      require_authentication = true
      require_https          = true
      default_provider       = "AzureActiveDirectory"

      active_directory_v2 {
        client_id                  = local.client_app_id
        tenant_auth_endpoint       = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
        allowed_applications       = [local.client_app_id]
        client_secret_setting_name = var.client_secret_setting_name
        allowed_audiences          = ["api://${local.server_app_id}"]
        login_parameters           = { scope = "${join(" ", ["api://${local.server_app_id}/.default", "openid", "profile", "email", "offline_access"])}" }
      }
      login {
        token_store_enabled = true
      }
    }
  }

  client_certificate_enabled               = false
  client_certificate_mode                  = "Required"
  enabled                                  = true
  ftp_publish_basic_authentication_enabled = false
  https_only                               = true
  key_vault_reference_identity_id          = var.webapp_user_assigned_identity_id
  public_network_access_enabled            = false
  service_plan_id                          = azurerm_service_plan.service_plan.id
  virtual_network_subnet_id                = var.integration_subnet_id
  site_config {
    app_command_line = "python3 -m gunicorn main:app"
    always_on        = var.webapp_always_on

    application_stack {
      python_version = "3.11"
    }
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    ip_restriction_default_action     = "Allow"
    load_balancing_mode               = "LeastRequests"
    managed_pipeline_mode             = "Integrated"
    minimum_tls_version               = "1.2"
    remote_debugging_enabled          = false
    scm_use_main_ip_restriction       = false
    scm_ip_restriction_default_action = "Allow" # Must be updated for prod environment to "Deny"
    scm_minimum_tls_version           = "1.2"
    use_32_bit_worker                 = false
    vnet_route_all_enabled            = false
    websockets_enabled                = false
  }
  webdeploy_publish_basic_authentication_enabled = false

  logs {
    application_logs {
      file_system_level = "Verbose"
    }
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_mb   = 35
        retention_in_days = 1
      }
    }
  }
}
