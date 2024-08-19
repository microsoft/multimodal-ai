locals {
  mmai_text_indexer_json = templatefile("${path.module}/lib/indexer_template.json", {
    indexer_Name    = "${module.ai_search.search_service_name}-text-indexer",
    dataSourceName  = jsondecode(restapi_object.ai_search_datasource_mmai_text.api_response).name
    targetIndexName = jsondecode(restapi_object.ai_search_index_mmai_text.api_response).name
    skillsetName    = jsondecode(restapi_object.ai_search_skillsets_mmai_text.api_response).name
  })
}

// https://learn.microsoft.com/en-us/rest/api/searchservice/preview-api/create-or-update-indexer
resource "restapi_object" "ai_search_indexer_mmai_text" {
  path         = "/indexers"
  query_string = "api-version=2024-05-01-Preview "
  data         = local.mmai_text_indexer_json
  id_attribute = "name" # The ID field on the response
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text,
    restapi_object.ai_search_index_mmai_text,
    restapi_object.ai_search_skillsets_mmai_text,
  ]
}