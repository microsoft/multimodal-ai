
locals {
  indexer_config_file = "indexer_config.json"
}

resource "local_file" "indexer_config" {
  content = templatefile("${path.module}/../../../library/indexer_template.json", {
    datasource_name     = var.search_service_datasource_name
    index_name          = var.search_service_index_name
    indexer_name        = var.search_service_indexer_name
    indexer_description = "Indexer for auto indexing documents with ${var.search_service_skillset_name}"
    skillset_name       = var.search_service_skillset_name
  })
  filename = "${path.module}/${local.indexer_config_file}"
}

# wait for permissions to propogate
resource "time_sleep" "wait_5mins" {
  depends_on      = [azurerm_role_assignment.storage_blob_data_to_search_service, azurerm_role_assignment.knowledgestore_blob_data_to_search_service]
  create_duration = "5m"
}

resource "null_resource" "create_indexer" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${local.get_access_token_command}
      az rest --method PUT ${local.line_separator}
        --url ${local.escape_char}"https://${var.search_service_name}.search.windows.net/indexers${local.escape_char}(${local.escape_char}'${var.search_service_indexer_name}${local.escape_char}'${local.escape_char})?api-version=2024-05-01-preview${local.escape_char}" ${local.line_separator}
        --headers ${local.escape_char}"Content-Type=application/json${local.escape_char}" ${local.escape_char}"Authorization=Bearer $ACCESS_TOKEN${local.escape_char}" ${local.line_separator}
        --body ${local.escape_char}@${path.module}${local.path_separator}${local.indexer_config_file}
      ${format(local.delete_file_command, local.indexer_config_file)}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [azurerm_search_service.search_service, local_file.indexer_config, null_resource.create_datasource, null_resource.create_index, null_resource.create_skillset, time_sleep.wait_5mins]
}
