# resource "restapi_object" "ai_search_debugsession_mmai_text" {
#   path         = "/debugsessions"
#   query_string = "api-version=2024-05-01-Preview"
#   data         = jsonencode({
#     "name" = "test" #formatdate("02-01-15-04", timestamp()),
#     "storageConnectionString" = module.storage_account.storage_account_primary_connection_string,
#     "documentSelectorKey" = null,
#     "skillset" =  jsondecode(local.mmai_text_skillsets_json),
#     "indexer" = jsondecode(local.mmai_text_indexer_json)
#   })
#   id_attribute = "name" # The ID field on the response
#   depends_on = [
#     module.ai_search,
#     restapi_object.ai_search_datasource_mmai_text,
#     restapi_object.ai_search_index_mmai_text,
#     restapi_object.ai_search_skillsets_mmai_text,
#     restapi_object.ai_search_indexer_mmai_text,
#     data.http.ai_search_indexer_mmai_text_reset,
#     data.http.ai_search_indexer_mmai_text_run
#   ]
# }