locals {
  mmai_text_index_json = templatefile("${path.module}/lib/index_template.json", {
    index_name =  "${module.ai_search.search_service_name}-index-text",
  })
}

# https://learn.microsoft.com/en-us/rest/api/searchservice/create-index
resource "restapi_object" "ai_search_index_mmai_text" {
  path         = "/indexes"
  query_string = "api-version=2024-07-01"
  data         = local.mmai_text_index_json
  id_attribute = "name"
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text
  ]
}