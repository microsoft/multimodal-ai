# Define the resource group
resource "azurerm_resource_group" "resource_group" {
  name     = "${local.prefix}-mmai-rg"
  location = "East US"
}