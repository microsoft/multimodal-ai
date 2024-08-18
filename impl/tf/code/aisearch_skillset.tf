locals {
  mmai_text_skillsets_json = templatefile("${path.module}/lib/skillset_template.json", {
    skillset_name =  "${module.ai_search.search_service_name}-text-skillset",
    resource_uri = module.openai.cognitive_account_endpoint
    api_key = module.openai.azurerm_cognitive_account_primary_access_key
    deployment_id = "text-embedding-3-large"
    model_name = "text-embedding-3-large"
  })
}
# Create
// https://learn.microsoft.com/en-us/rest/api/searchservice/preview-api/create-or-update-indexer
resource "restapi_object" "ai_search_skillsets_mmai_text" {
  path         = "/skillsets"
  query_string = "api-version=2024-07-01"
  data         = local.mmai_text_skillsets_json
  id_attribute = "name" # The ID field on the response
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text,
    restapi_object.ai_search_index_mmai_text
  ]
}