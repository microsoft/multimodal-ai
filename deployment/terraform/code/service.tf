# module "network" {
#   source = "./modules/network"

#   location       = var.location
#   tags           = var.tags
#   vnet_id        = var.vnet_id
#   nsg_id         = var.nsg_id
#   route_table_id = var.route_table_id
# }

# module "user_assigned_identity" {
#   source = "./modules/userassignedidentity"

#   location                    = var.location
#   tags                        = var.tags
#   resource_group_name         = azurerm_resource_group.services_rg.name
#   user_assigned_identity_name = "${local.prefix}-uai001"
# }

# module "key_vault" {
#   source = "./modules/keyvault"

#   location                      = var.location
#   tags                          = var.tags
#   resource_group_name           = azurerm_resource_group.services_rg.name
#   key_vault_name                = "${local.prefix}-vault001"
#   cmk_uai_id                    = module.user_assigned_identity.user_assigned_identity_id
#   subnet_id                     = module.network.subnet_private_endpoints_id
#   private_dns_zone_id_key_vault = module.network.private_dns_zone_key_vault_id
# }

# module "bastion" {
#   source = "./modules/bastion"

#   location            = var.location
#   tags                = var.tags
#   resource_group_name = azurerm_resource_group.bastion_rg.name
#   admin_password      = var.admin_password
#   admin_username      = var.admin_username
#   bastion_name        = "${local.prefix}-bas001"
#   vm_name             = "${local.prefix}-vm001"
#   subnet_bastion_id   = module.network.subnet_bastion_id
#   subnet_compute_id   = module.network.subnet_compute_id
#   cmk_uai_id          = module.user_assigned_identity.user_assigned_identity_id
#   cmk_key_vault_id    = module.key_vault.key_vault_id
#   cmk_key_name        = module.key_vault.key_vault_cmk_name
# }

# module "cognitive_service" {
#   source = "./modules/cognitiveservices"

#   location                              = var.location
#   tags                                  = var.tags
#   resource_group_name                   = azurerm_resource_group.services_rg.name
#   cognitive_service_name                = "${local.prefix}-cog001"
#   cognitive_service_kind                = "CognitiveServices"
#   cognitive_service_sku                 = "S0"
#   subnet_id                             = module.network.subnet_private_endpoints_id
#   cmk_uai_id                            = module.user_assigned_identity.user_assigned_identity_id
#   cmk_key_vault_id                      = module.key_vault.key_vault_id
#   cmk_key_name                          = module.key_vault.key_vault_cmk_name
#   private_dns_zone_id_cognitive_service = module.network.private_dns_zone_cognitive_service_id
# }

# module "storage" {
#   source = "./modules/storage"

#   location                 = var.location
#   tags                     = var.tags
#   resource_group_name      = azurerm_resource_group.services_rg.name
#   storage_name             = replace("${local.prefix}-stg001", "-", "")
#   storage_container_names  = ["data"]
#   subnet_id                = module.network.subnet_private_endpoints_id
#   cmk_uai_id               = module.user_assigned_identity.user_assigned_identity_id
#   cmk_key_vault_id         = module.key_vault.key_vault_id
#   cmk_key_name             = module.key_vault.key_vault_cmk_name
#   private_dns_zone_id_blob = module.network.private_dns_zone_blob_id
# }

# module "logging" {
#   source = "./modules/logging"

#   location                     = var.location
#   tags                         = var.tags
#   resource_group_name          = azurerm_resource_group.logging_rg.name
#   application_insights_name    = "${local.prefix}-appi001"
#   log_analytics_workspace_name = "${local.prefix}-log001"
# }

# module "apimanagement" {
#   source = "./modules/apimanagement"

#   location                = var.location
#   tags                    = var.tags
#   resource_group_name     = azurerm_resource_group.services_rg.name
#   api_management_name     = "${local.prefix}-apim001"
#   api_management_sku      = "Developer"
#   api_management_capacity = 1
#   subnet_id               = module.network.subnet_apim_id
#   api_management_email    = var.api_management_email
#   publisher_name          = var.publisher_name
#   encoded_certificate     = ""
# }
