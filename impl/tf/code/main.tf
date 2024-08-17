# Define the resource group
resource "azurerm_resource_group" "mmai" {
  name     = "${local.prefix}-mmai-rg"
  location = local.location
}

resource "azurerm_resource_group" "storage" {
  name     = "${local.prefix}-storage-rg"
  location = local.location
}

resource azurerm_resource_group "monitoring" {
  name     = "${local.prefix}-monitoring-rg"
  location = local.location
}

resource azurerm_user_assigned_identity "user_assigned_identity" {
  name                = "${local.prefix}-umi"
  location            = local.location
  resource_group_name = azurerm_resource_group.mmai.name
}