module "key_vault" {
  source                        = "../infra/modules/keyvault"
  location                      = var.location
  tags                          = var.tags
  resource_group_name           = azurerm_resource_group.resource_group_container_app.name
  log_analytics_workspace_id    = var.log_analytics_workspace_id
  key_vault_name                = "${local.prefix}-kv001"
  key_vault_sku_name            = "standard"
  subnet_id                     = azapi_resource.subnet_private_endpoints.id
  private_dns_zone_id_key_vault = var.private_dns_zone_id_vault
  vnet_location                 = data.azurerm_virtual_network.virtual_network.location
  public_network_access_enabled = false
}

resource "azurerm_key_vault_secret" "key_vault_secret_github_pat" {
  name         = "github-pat"
  key_vault_id = module.key_vault.key_vault_id

  content_type = "text/plain"
  value        = var.github_personal_access_token

  depends_on = [
    azurerm_role_assignment.current_role_assignment_key_vault_secrets_officer,
    module.key_vault
  ]
}
