resource "azurerm_resource_group" "resource_group" {
  name     = "${local.abbrs.resourcesResourceGroups}${local.prefix}-prereq"
  location = var.location
  tags     = var.tags
}
