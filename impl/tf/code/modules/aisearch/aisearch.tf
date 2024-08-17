resource "azurerm_search_service" "search_service" {
  name                = var.search_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  # only system assigned identity is supported
  identity {
    type = "SystemAssigned"
  }
  # identity {
  #   type = var.user_assigned_identity_id != "" ? "UserAssigned" : "SystemAssigned"
  #   identity_ids = var.user_assigned_identity_id != "" ? [var.user_assigned_identity_id] : null
  # }


  allowed_ips                 = []
  # authentication_failure_mode = "http401WithBearerChallenge"
  hosting_mode                = "default"

  sku                                      = var.search_service_sku
  partition_count                          = var.search_service_partition_count
  replica_count                            = var.search_service_replica_count
  public_network_access_enabled            = true
  local_authentication_enabled             = true
  customer_managed_key_enforcement_enabled = false
}

resource "azurerm_role_assignment" "identity_access_to_search" {
  principal_id = data.azurerm_user_assigned_identity.user_assigned_identity.principal_id
  scope        = azurerm_search_service.search_service.id
  role_definition_name = "Search Index Data Contributor"
}