
locals {
  index_config_file = "index_config.json"
}

data "template_file" "index_template" {
  template = file("${path.module}/../../../library/index_template.json")

  vars = {
    index_name                     = var.search_service_index_name
    azureOpenAI_endpoint           = var.azure_openai_endpoint
    azureOpenAI_text_deployment_id = var.azure_openai_text_deployment_id
    azureOpenAI_text_model_name    = var.azure_openai_text_model_name
    cognitive_services_endpoint    = var.computer_vision_endpoint
  }
}

resource "local_file" "index_config" {
  content  = data.template_file.index_template.rendered
  filename = "${path.module}/${local.index_config_file}"
}

resource "null_resource" "create_index" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${local.get_access_token_command}
      az rest --method PUT ${local.line_separator}
        --url ${local.escape_char}"https://${var.search_service_name}.search.windows.net/indexes${local.escape_char}(${local.escape_char}'${var.search_service_index_name}${local.escape_char}'${local.escape_char})?api-version=2024-05-01-preview${local.escape_char}" ${local.line_separator}
        --headers ${local.escape_char}"Content-Type=application/json${local.escape_char}" ${local.escape_char}"Authorization=Bearer $ACCESS_TOKEN${local.escape_char}" ${local.line_separator}
        --body ${local.escape_char}@${path.module}${local.path_separator}${local.index_config_file}
      ${format(local.delete_file_command, local.index_config_file)}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [azurerm_search_service.search_service, local_file.index_config, azurerm_role_assignment.storage_blob_data_to_search_service, azurerm_role_assignment.search_index_data_contributor]
}
