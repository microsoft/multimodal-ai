locals {
  mmai_text_skillsets_json = templatefile("${path.module}/lib/skillset_template.json", {
    skillset_name     = local.ai_search_skillset_name
    resource_uri      = module.openai.cognitive_account_endpoint
    api_key           = module.openai.azurerm_cognitive_account_primary_access_key
    deployment_id     = local.embedding_deployment
    model_name        = local.embedding_model
    target_index_name = local.ai_search_index_name
  })
}
# Create
// https://learn.microsoft.com/en-us/rest/api/searchservice/preview-api/create-or-update-indexer
resource "restapi_object" "ai_search_skillsets_mmai_text" {
  path         = "/skillsets"
  query_string = "api-version=2024-05-01-preview"
  data         = local.mmai_text_skillsets_json
  id_attribute = "name" # The ID field on the response
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text,
    restapi_object.ai_search_index_mmai_text
  ]
}
