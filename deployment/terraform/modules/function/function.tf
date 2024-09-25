resource "azurerm_linux_function_app" "linux_function_app" {
  name                = var.function_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  identity {
    type = var.function_user_assigned_identity_id != "" && var.function_user_assigned_identity_id != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    #identity_ids = var.function_user_assigned_identity_id  != "" ? [var.function_user_assigned_identity_id] : []
    identity_ids = try(var.function_user_assigned_identity_id != "" && var.function_user_assigned_identity_id != null ? [var.function_user_assigned_identity_id] : [], [])
  }

  app_settings                             = local.function_application_settings
  builtin_logging_enabled                  = true
  client_certificate_enabled               = false
  client_certificate_mode                  = "Required"
  content_share_force_disabled             = false
  enabled                                  = true
  daily_memory_time_quota                  = 0
  ftp_publish_basic_authentication_enabled = false
  functions_extension_version              = "~4"
  https_only                               = true
  key_vault_reference_identity_id          = var.function_user_assigned_identity_id
  public_network_access_enabled            = true
  service_plan_id                          = azurerm_service_plan.service_plan.id
  site_config {
    always_on       = var.function_always_on
    app_scale_limit = 200
    app_service_logs {
      retention_period_days = 0
    }
    application_insights_connection_string = var.function_application_insights_connection_string
    application_insights_key               = var.function_application_insights_instrumentation_key
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
  storage_account_name                           = data.azurerm_storage_account.storage_account.name
  storage_uses_managed_identity                  = true
  webdeploy_publish_basic_authentication_enabled = false

  auth_settings_v2 {
    auth_enabled           = true
    unauthenticated_action = "Return401"
    require_authentication = true
    require_https          = true
    active_directory_v2 {
      # allowed_audiences = [
      #   "${managed_identity_application_id}"
      # ]
      client_id            = local.function_ad_app_client_id
      tenant_auth_endpoint = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    }
    login {
      token_store_enabled = true
    }
  }
}
