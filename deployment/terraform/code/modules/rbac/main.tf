data "azurerm_role_definition" "id" {
  name = var.roleDefinition_name
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = var.scope
  role_definition_name = var.roleDefinition_name
  principal_id         = var.principalId
  principal_type       = var.principalType
}

