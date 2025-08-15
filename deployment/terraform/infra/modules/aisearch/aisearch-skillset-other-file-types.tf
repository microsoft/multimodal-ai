locals {
  skillset_other_file_types_config_file = "skillset_config_other_file_types.json"
}

resource "local_file" "skillset_other_file_types_config" {
  content = templatefile("${path.module}/../../../../library/skillset_other_file_types_template.json", {
    index_name                              = var.search_service_index_name
    skillset_name                           = var.search_service_skillset_other_file_types_name
    azureOpenAI_endpoint                    = var.azure_openai_endpoint
    azureOpenAI_text_deployment_id          = var.azure_openai_text_deployment_id
    azureOpenAI_text_model_name             = var.azure_openai_text_model_name
    cognitiveServices_multiService_endpoint = var.cognitive_services_endpoint
  })
  filename = "${path.module}/${local.skillset_other_file_types_config_file}"
}


resource "null_resource" "create_skillset_other_file_types" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${local.get_access_token_command}
      az rest --method PUT ${local.line_separator}
        --url ${local.escape_char}"https://${var.search_service_name}.search.windows.net/skillsets${local.escape_char}(${local.escape_char}'${var.search_service_skillset_other_file_types_name}${local.escape_char}'${local.escape_char})?api-version=2024-11-01-preview${local.escape_char}" ${local.line_separator}
        --headers ${local.escape_char}"Content-Type=application/json${local.escape_char}" ${local.escape_char}"Authorization=Bearer $ACCESS_TOKEN${local.escape_char}" ${local.line_separator}
        --body ${local.escape_char}@${path.module}${local.path_separator}${local.skillset_other_file_types_config_file}
      ${format(local.delete_file_command, local.skillset_other_file_types_config_file)}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    azurerm_search_service.search_service,
    local_file.skillset_other_file_types_config,
    null_resource.create_index,
    null_resource.create_datasource,
    null_resource.create_skillset,
    null_resource.create_indexer,
    azapi_update_resource.function_azure_search_private_endpoint_approver
  ]
}
