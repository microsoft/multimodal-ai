locals {
  datasource_config_file = "datasource_config.json"
}

# data "template_file" "datasource_template" {
#   template = file("${path.module}/../../../library/datasource_blob_template.json")

#   vars = {
#     datasource_name                   = var.search_service_datasource_name
#     datasource_description            = "Data source for indexing documents from Azure Blob Storage"
#     storage_account_connection_string = "ResourceId=${var.storage_account_id}"
#     container_name                    = var.storage_container_name_content
#   }
# }

resource "local_file" "datasource_config" {
  # content  = data.template_file.datasource_template.rendered
  content = templatefile("${path.module}/../../../library/datasource_blob_template.json", {
    datasource_name                   = var.search_service_datasource_name
    datasource_description            = "Data source for indexing documents from Azure Blob Storage"
    storage_account_connection_string = "ResourceId=${var.storage_account_id}"
    container_name                    = var.storage_container_name_content
  })
  filename = "${path.module}/${local.datasource_config_file}"
}


resource "null_resource" "create_datasource" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<-EOT
      ${local.get_access_token_command}
      az rest --method PUT ${local.line_separator}
          --url ${local.escape_char}"https://${var.search_service_name}.search.windows.net/datasources${local.escape_char}(${local.escape_char}'${var.search_service_datasource_name}${local.escape_char}'${local.escape_char})?api-version=2024-07-01${local.escape_char}" ${local.line_separator}
          --headers ${local.escape_char}"Content-Type=application/json${local.escape_char}" ${local.escape_char}"Authorization=Bearer $ACCESS_TOKEN${local.escape_char}" ${local.line_separator}
          --body ${local.escape_char}@${path.module}${local.path_separator}${local.datasource_config_file}
      ${format(local.delete_file_command, local.datasource_config_file)}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [azurerm_search_service.search_service, local_file.datasource_config, azurerm_role_assignment.storage_blob_data_to_search_service, azurerm_role_assignment.search_index_data_contributor]
}
