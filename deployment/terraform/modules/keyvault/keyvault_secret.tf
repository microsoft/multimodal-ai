resource "azurerm_key_vault_secret" "key_vault_secret" {
  count = length(var.key_vault_secrets) # for_each = var.key_vault_secrets

  name         = var.key_vault_secrets[count.index].secret_name
  value        = var.key_vault_secrets[count.index].secret_value # each.value
  key_vault_id = azurerm_key_vault.key_vault.id

  depends_on = [
    azurerm_role_assignment.current_role_assignment_key_vault
  ]
}
