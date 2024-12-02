locals {
  infra_tfvars = <<-EOT
# Logging variables
log_analytics_workspace_id = "${module.loganalytics.log_analytics_workspace_id}"

# Network variables
connectivity_delay_in_seconds = 0
vnet_id                       = "${azurerm_virtual_network.virtual_network.id}"
nsg_id                        = "${azurerm_network_security_group.network_security_group.id}"
route_table_id                = "${azurerm_route_table.route_table.id}"
subnet_cidr_function          = "10.0.0.0/26"
subnet_cidr_private_endpoints = "10.0.0.64/26"

# DNS variables
private_dns_zone_id_blob               = "${azurerm_private_dns_zone.private_dns_zone["blob"].id}"
private_dns_zone_id_queue              = "${azurerm_private_dns_zone.private_dns_zone["queue"].id}"
private_dns_zone_id_table              = "${azurerm_private_dns_zone.private_dns_zone["table"].id}"
private_dns_zone_id_file               = "${azurerm_private_dns_zone.private_dns_zone["file"].id}"
private_dns_zone_id_vault              = "${azurerm_private_dns_zone.private_dns_zone["vault"].id}"
private_dns_zone_id_sites              = "${azurerm_private_dns_zone.private_dns_zone["sites"].id}"
private_dns_zone_id_open_ai            = "${azurerm_private_dns_zone.private_dns_zone["open_ai"].id}"
private_dns_zone_id_cognitive_services = "${azurerm_private_dns_zone.private_dns_zone["cognitive_services"].id}"
  EOT
}

resource "local_file" "infra_tfvars" {
  filename = "../infra/prereqs.tfvars"
  content  = local.infra_tfvars
}
