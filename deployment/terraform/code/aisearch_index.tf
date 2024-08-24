locals {
  mmai_text_index_json = templatefile("${path.module}/lib/index_template.json", {
    index_name                     = local.ai_search_index_name
    azureOpenAI_endpoint           = module.openai.cognitive_account_endpoint
    aoai_api_key                   = module.openai.azurerm_cognitive_account_primary_access_key
    cognitive_service_endpoint     = module.conginitiveservice.cognitive_account_endpoint
    cognitive_service_api_key      = module.conginitiveservice.azurerm_cognitive_account_primary_access_key
    azureOpenAI_text_deployment_id = local.embedding_deployment
    azureOpenAI_text_model_name    = local.embedding_model
  })
}

# https://learn.microsoft.com/en-us/rest/api/searchservice/create-index
resource "restapi_object" "ai_search_index_mmai_text" {
  path         = "/indexes"
  query_string = "api-version=2024-05-01-Preview " #"api-version=2024-07-01"
  data         = local.mmai_text_index_json
  id_attribute = "name"
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text
  ]
}
