resource "azurerm_cognitive_account" "cognitive_service" {
  name                = var.cognitive_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  identity {
    type = "SystemAssigned"
  }

  custom_subdomain_name = var.cognitive_service_name
  # customer_managed_key {
  #   key_vault_key_id   = var.customer_managed_key.key_vault_key_versionless_id
  #   identity_client_id = var.customer_managed_key.user_assigned_identity_client_id
  # }
  dynamic_throttling_enabled = false
  fqdns = [
    # "${reverse(split(var.customer_managed_key.key_vault_id, "/"))[0]}.vault.azure.net",
  ]
  kind               = var.cognitive_service_kind
  local_auth_enabled = var.local_auth_enabled
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = []
  }
  outbound_network_access_restricted = false
  public_network_access_enabled      = true
  sku_name                           = var.cognitive_service_sku
}
