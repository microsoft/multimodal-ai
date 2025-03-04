data "azurerm_client_config" "current" {}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories_search_service" {
  resource_id = azurerm_search_service.search_service.id
}
data "azapi_resource" "openai_account_pe_connections" {
  type                   = "Microsoft.CognitiveServices/accounts@2024-10-01"
  depends_on             = [azurerm_search_shared_private_link_service.shared_private_link_search_service_aoai]
  resource_id            = var.openai_account_id
  response_export_values = ["properties.privateEndpointConnections"]
}
data "azapi_resource" "vision_account_pe_connections" {
  type                   = "Microsoft.CognitiveServices/accounts@2024-10-01"
  depends_on             = [azurerm_search_shared_private_link_service.shared_private_link_ai_vision]
  resource_id            = var.vision_id
  response_export_values = ["properties.privateEndpointConnections"]
}
data "azapi_resource" "form_recognizer_account_pe_connections" {
  type                   = "Microsoft.CognitiveServices/accounts@2024-10-01"
  depends_on             = [azurerm_search_shared_private_link_service.shared_private_link_form_recognition]
  resource_id            = var.form_recognizer_id
  response_export_values = ["properties.privateEndpointConnections"]
}
data "azapi_resource" "ai_multi_account_pe_connections" {
  type                   = "Microsoft.CognitiveServices/accounts@2024-10-01"
  depends_on             = [azurerm_search_shared_private_link_service.shared_private_link_ai_multi-service]
  resource_id            = var.cognitive_account_id
  response_export_values = ["properties.privateEndpointConnections"]
}
data "azapi_resource" "function_pe_connections" {
  type                   = "Microsoft.Web/sites@2024-10-01"
  depends_on             = [azurerm_search_shared_private_link_service.shared_private_link_search_service_aoai]
  resource_id            = var.function_id
  response_export_values = ["properties.privateEndpointConnections"]
}
data "azapi_resource" "storage_account_pe_connections" {
  type                   = "Microsoft.Storage/storageAccounts@2024-01-01"
  depends_on             = [azurerm_search_shared_private_link_service.shared_private_link_search_service_blob]
  resource_id            = var.storage_account_id
  response_export_values = ["properties.privateEndpointConnections"]
}

locals {
  is_windows     = length(regexall("^[a-z]:", lower(abspath(path.root)))) > 0
  line_separator = local.is_windows ? "`" : "\\"
  path_separator = local.is_windows ? "/" : "/"
  escape_char    = local.is_windows ? "`" : ""

  get_access_token_command_for_windows = "$ACCESS_TOKEN=(az account get-access-token  --scope https://search.azure.com/.default --query accessToken --output tsv)"
  get_access_token_command_for_linux   = "ACCESS_TOKEN=$(az account get-access-token  --scope https://search.azure.com/.default --query accessToken --output tsv)"
  get_access_token_command             = local.is_windows ? local.get_access_token_command_for_windows : local.get_access_token_command_for_linux

  delete_file_command_for_windows = "del ${path.module}${local.path_separator}%s"
  delete_file_command_for_linux   = "rm ${path.module}${local.path_separator}%s"
  delete_file_command             = local.is_windows ? local.delete_file_command_for_windows : local.delete_file_command_for_linux

  vision_pe_connection_id = one([
    for connection in data.azapi_resource.vision_account_pe_connections.output.properties.privateEndpointConnections
    : connection.id
    if strcontains(connection.properties.privateEndpoint.id, var.search_service_name)
  ])

  form_recognizer_pe_connection_id = one([
    for connection in data.azapi_resource.form_recognizer_account_pe_connections.output.properties.privateEndpointConnections
    : connection.id
    if strcontains(connection.properties.privateEndpoint.id, var.search_service_name)
  ])

  ai_multi_account_pe_connection_id = one([
    for connection in data.azapi_resource.ai_multi_account_pe_connections.output.properties.privateEndpointConnections
    : connection.id
    if strcontains(connection.properties.privateEndpoint.id, var.search_service_name)
  ])

  function_pe_connection_id = one([
    for connection in data.azapi_resource.function_pe_connections.output.properties.privateEndpointConnections
    : connection.id
    if strcontains(connection.properties.privateEndpoint.id, var.search_service_name)
  ])

  openai_pe_connection_id = one([
    for connection in data.azapi_resource.openai_account_pe_connections.output.properties.privateEndpointConnections
    : connection.id
    if strcontains(connection.properties.privateEndpoint.id, var.search_service_name)
  ])

  blob_pe_connection_id = one([
    for connection in data.azapi_resource.storage_account_pe_connections.output.properties.privateEndpointConnections
    : connection.id
    if strcontains(connection.properties.privateEndpoint.id, var.search_service_name)
  ])
}
