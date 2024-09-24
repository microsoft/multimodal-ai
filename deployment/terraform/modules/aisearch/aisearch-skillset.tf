locals {
  skillset_config_file = "skillset_config.json"
}

# data "template_file" "skillset_template" {
#   template = file("${path.module}/../../../library/skillset_template.json")

#   vars = {
#     index_name                                = var.search_service_index_name
#     skillset_name                             = var.search_service_skillset_name
#     azureOpenAI_endpoint                      = var.azure_openai_endpoint
#     azureOpenAI_text_deployment_id            = var.azure_openai_text_deployment_id
#     azureOpenAI_text_model_name               = var.azure_openai_text_model_name
#     pdf_text_image_merge_skill_url            = var.pdf_merge_customskill_endpoint
#     cognitiveServices_multiService_accountKey = var.cognitive_services_key # https://learn.microsoft.com/azure/search/cognitive-search-attach-cognitive-services?tabs=portal%2Cportal-remove#how-the-key-is-used
#     storage_account_resource_uri              = "ResourceId=${var.knowledgestore_storage_account_id}"
#     storage_account_image_container_name      = var.storage_container_name_knowledgestore
#     aad_app_id                                = var.function_app_id
#   }
# }

resource "local_file" "skillset_config" {
  #content  = data.template_file.skillset_template.rendered
  content = templatefile("${path.module}/../../../library/skillset_template.json", {
    index_name                                = var.search_service_index_name
    skillset_name                             = var.search_service_skillset_name
    azureOpenAI_endpoint                      = var.azure_openai_endpoint
    azureOpenAI_text_deployment_id            = var.azure_openai_text_deployment_id
    azureOpenAI_text_model_name               = var.azure_openai_text_model_name
    pdf_text_image_merge_skill_url            = var.pdf_merge_customskill_endpoint
    cognitiveServices_multiService_accountKey = var.cognitive_services_key # https://learn.microsoft.com/azure/search/cognitive-search-attach-cognitive-services?tabs=portal%2Cportal-remove#how-the-key-is-used
    storage_account_resource_uri              = "ResourceId=${var.knowledgestore_storage_account_id}"
    storage_account_image_container_name      = var.storage_container_name_knowledgestore
    aad_app_id                                = var.function_app_id
  })
  filename = "${path.module}/${local.skillset_config_file}"
}


resource "null_resource" "create_skillset" {
  provisioner "local-exec" {
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
    command     = <<EOT
      ${local.get_access_token_command}
      az rest --method PUT ${local.line_separator}
        --url ${local.escape_char}"https://${var.search_service_name}.search.windows.net/skillsets${local.escape_char}(${local.escape_char}'${var.search_service_skillset_name}${local.escape_char}'${local.escape_char})?api-version=2024-05-01-preview${local.escape_char}" ${local.line_separator}
        --headers ${local.escape_char}"Content-Type=application/json${local.escape_char}" ${local.escape_char}"Authorization=Bearer $ACCESS_TOKEN${local.escape_char}" ${local.line_separator}
        --body ${local.escape_char}@${path.module}${local.path_separator}${local.skillset_config_file}
      ${format(local.delete_file_command, local.skillset_config_file)}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [azurerm_search_service.search_service, local_file.skillset_config, null_resource.create_index, azurerm_role_assignment.knowledgestore_blob_data_to_search_service]
}
