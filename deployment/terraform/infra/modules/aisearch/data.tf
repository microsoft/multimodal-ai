data "azurerm_client_config" "current" {}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories_search_service" {
  resource_id = azurerm_search_service.search_service.id
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
}
