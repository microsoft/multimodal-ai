resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "${local.abbrs.resourcesResourceGroups}${var.environment_name}-${local.resourceToken}"
  location = var.location
  tags     = local.tags
}
