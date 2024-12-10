resource "azurerm_service_plan" "service_plan" {
  name                = "${var.webapp_name}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name

  # maximum_elastic_worker_count = 20 # only valid for elastic premium skus e.g EP1, EP2, EP3
  os_type                  = "Linux"
  per_site_scaling_enabled = false
  sku_name                 = var.webapp_sku
  worker_count             = 1     # Update to '3' for production
  zone_balancing_enabled   = false # Update to 'true' for production
}
