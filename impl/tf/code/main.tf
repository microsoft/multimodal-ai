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

module "user_assigned_identity" {
  source = "./modules/managedidentity"
  user_assigned_identity_name = "${local.prefix}-umi"
  location = local.location
  resource_group_name = azurerm_resource_group.mmai.name
  tags = var.tags
}