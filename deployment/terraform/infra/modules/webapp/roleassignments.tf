resource "azurerm_role_assignment" "webapp_rolesassignment_key_vault_administrator" {
  scope                = var.webapp_key_vault_id #data.azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.linux_webapp.identity[0].principal_id
}
