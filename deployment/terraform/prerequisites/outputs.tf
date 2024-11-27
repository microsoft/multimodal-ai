output "virtual_network_id" {
  description = "Specifies the id of the virtual network."
  sensitive   = false
  value       = azurerm_virtual_network.virtual_network.id
}

output "route_table_id" {
  description = "Specifies the id of the route table."
  sensitive   = false
  value       = azurerm_route_table.route_table.id
}

output "network_security_group_id" {
  description = "Specifies the id of the network security group."
  sensitive   = false
  value       = azurerm_network_security_group.network_security_group.id
}

output "private_dns_zone_ids" {
  description = "Specifies the ids of the private dns zones."
  sensitive   = false
  value = [
    for key, value in local.private_dns_zone_names :
    azurerm_private_dns_zone.private_dns_zone[key].id
  ]
}
