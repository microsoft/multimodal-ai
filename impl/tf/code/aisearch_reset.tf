#  Reset - https://learn.microsoft.com/en-us/rest/api/searchservice/indexers/reset?view=rest-searchservice-2024-07-01&tabs=HTTP
data "http" "ai_search_indexer_mmai_text_reset" {
  url    = "https://${local.ai_search_name}.search.windows.net/indexers/${jsondecode(restapi_object.ai_search_indexer_mmai_text.api_response).name}/reset?api-version=2024-07-01"
  method = "POST"
  request_headers = {
    "api-key"      = module.ai_search.search_service_key
    "Content-Type" = "application/json"
  }
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text,
    restapi_object.ai_search_index_mmai_text,
    restapi_object.ai_search_skillsets_mmai_text,
    restapi_object.ai_search_indexer_mmai_text,
  ]
}

# resource "restapi_object" "ai_search_indexer_reset_mmai_text" {
#   path         = "/indexers/${jsondecode(restapi_object.ai_search_indexer_mmai_text.api_response).name}/reset"
#   query_string = "api-version=2024-07-01"

#   id_attribute = "/" # The ID field on the response
#   data = ""
#   depends_on = [
#     module.ai_search,
#     restapi_object.ai_search_datasource_mmai_text,
#     restapi_object.ai_search_index_mmai_text,
#     restapi_object.ai_search_skillsets_mmai_text,
#     restapi_object.ai_search_indexer_mmai_text,
#   ]
# }