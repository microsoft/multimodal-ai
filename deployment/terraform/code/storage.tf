module "storage_account" {
  source = "./modules/storageaccount"

  location             = local.location
  resource_group_name  = azurerm_resource_group.storage.name
  tags                 = var.tags
  storage_account_name = local.storage_account_name
  storage_account_container_names = [
    local.container_name_text,
    local.container_name_multimedia,
  ]
  storage_account_share_names               = []
  storage_account_shared_access_key_enabled = true
  storage_account_hns_enabled               = true
  log_analytics_workspace_id                = module.azure_log_analytics.log_analytics_id
  subnet_id                                 = null
  customer_managed_key                      = null
}

resource "azurerm_storage_blob" "text_files" {
  depends_on = [module.storage_account]
  for_each = toset([
    for file in fileset(local.data_files_text, "**") : file
    if !startswith(file, ".gitkeep")
  ])

  name                   = each.value
  storage_account_name   = module.storage_account.storage_account_name
  storage_container_name = local.container_name_text
  type                   = "Block"
  source                 = "${local.data_files_text}/${each.value}"
}

resource "azurerm_storage_blob" "multimedia_files" {
  depends_on = [module.storage_account]
  for_each = toset([
    for file in fileset(local.data_files_multimedia, "**") : file
    if !startswith(file, ".gitkeep")
  ])

  name                   = each.value
  storage_account_name   = module.storage_account.storage_account_name
  storage_container_name = local.container_name_text
  type                   = "Block"
  source                 = "${local.data_files_multimedia}/${each.value}"
}