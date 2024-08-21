#  Reset - https://learn.microsoft.com/en-us/rest/api/searchservice/indexers/reset?view=rest-searchservice-2024-07-01&tabs=HTTP
data "http" "ai_search_indexer_mmai_text_run" {
  url    = "https://${local.ai_search_name}.search.windows.net/indexers/${jsondecode(restapi_object.ai_search_indexer_mmai_text.api_response).name}/run?api-version=2024-05-01-preview"
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
    data.http.ai_search_indexer_mmai_text_reset

    
  ]
}

# resource "null_resource" "ai_search_indexer_mmai_text_run" {
#   provisioner "local-exec" {
#     command = <<EOT
#       curl -X POST "https://${local.ai_search_name}.search.windows.net/indexers/${jsondecode(restapi_object.ai_search_indexer_mmai_text.api_response).name}/run?api-version=2024-07-01" \
#            -H "api-key: ${module.ai_search.search_service_key}" \
#            -H "Content-Type: application/json"
#     EOT
#   }

#   depends_on = [
#     module.ai_search,
#     restapi_object.ai_search_datasource_mmai_text,
#     restapi_object.ai_search_index_mmai_text,
#     restapi_object.ai_search_skillsets_mmai_text,
#     restapi_object.ai_search_indexer_mmai_text,
#     data.http.ai_search_indexer_mmai_text_reset
#   ]
# }


# // Run - https://learn.microsoft.com/en-us/rest/api/searchservice/preview-api/run-indexer
# resource "restapi_object" "ai_search_indexer_run_mmai_text" {
#   path         = "/indexers/${jsondecode(restapi_object.ai_search_indexer_mmai_text.api_response).name}/run"
#   query_string = "api-version=2024-07-01"
#   id_attribute = "name" # The ID field on the response
#   data = jsonencode(
#     {
#       id = "test"
#     }
#   )
#   depends_on = [
#     module.ai_search,
#     restapi_object.ai_search_datasource_mmai_text,
#     restapi_object.ai_search_index_mmai_text,
#     restapi_object.ai_search_skillsets_mmai_text,
#     restapi_object.ai_search_indexer_mmai_text,
#   ]
# }