locals {
  mmai_text_datasource_json = templatefile("${path.module}/lib/datasource_blob_template.json", {
    datasource_name                   = "${module.ai_search.search_service_name}-text-blob-datasource",
    storage_account_connection_string = module.storage_account.storage_account_primary_connection_string,
    container_name                    = local.container_name_text
  })
}

# https://learn.microsoft.com/en-us/rest/api/searchservice/create-data-source
resource "restapi_object" "ai_search_datasource_mmai_text" {
  path         = "/datasources"
  query_string = "api-version=2024-07-01"
  data         = local.mmai_text_datasource_json
  id_attribute = "name"
  depends_on = [
    module.storage_account,
    module.ai_search
  ]
}