# resource "azurerm_role_assignment" "current_role_assignment_key_vault_secrets_officer" {
#   scope                = module.key_vault.key_vault_id
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# # User Assigned Identity
# resource "azurerm_role_assignment" "uai_role_assignment_key_vault_secrets_user" {
#   scope                = module.key_vault.key_vault_id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = module.user_assigned_identity.user_assigned_identity_principal_id
# }
