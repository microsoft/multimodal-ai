module "ai_search" {
  source = "./modules/aisearch"

  location            = local.location
  resource_group_name = azurerm_resource_group.mmai.name
  tags                = var.tags

  search_service_name            = local.ai_search_name
  search_service_sku             = local.ai_search_sku
  search_service_partition_count = 1
  search_service_replica_count   = 1
  customer_managed_key           = null
  log_analytics_workspace_id     = module.azure_log_analytics.log_analytics_id
  user_assigned_identity_id      = module.user_assigned_identity.user_assigned_identity_id
  subnet_id                      = null

  # cognitive_service_kind = "search"
  # cognitive_service_name = local.ai_search_name
  # cognitive_service_sku = local.ai_search_sku

  # user_assigned_identity_id = azurerm_user_assigned_identity.user_assigned_identity.id
  # subnet_id = null
  # customer_managed_key = null
  # log_analytics_workspace_id = module.azure_log_analytics.log_analytics_id
}


locals {
  mmai_text_datasource_json = {
    name : "mmai-text-files-dataource",
    description : "mmai-text-files-dataource",
    type : "azureblob",
    credentials : {
      connectionString : module.storage_account.storage_account_primary_connection_string
    },
    container : {
      name : local.container_name_text
    },
    dataDeletionDetectionPolicy : {
      "@odata.type" : "#Microsoft.Azure.Search.NativeBlobSoftDeleteDeletionDetectionPolicy",
    },
  }
}


# https://learn.microsoft.com/en-us/rest/api/searchservice/create-data-source
resource "restapi_object" "ai_search_datasource_mmai_text" {
  path         = "/datasources"
  query_string = "api-version=2023-10-01-Preview"
  data         = jsonencode(local.mmai_text_datasource_json)
  id_attribute =  "name"
  depends_on = [
    module.storage_account,
    module.ai_search
  ]
}

locals {
  mmai_text_index_json = {
    name = "mmai-index-text-files-dataource",
    fields = [
      {
        name       = "id"
        type       = "Edm.String"
        searchable = false
        filterable = false
        sortable   = false
        key        = true
        facetable  = false
      },
      {
        name       = "metadata_storage_last_modified"
        type       = "Edm.DateTimeOffset"
        searchable = false
        filterable = true
        sortable   = false
        facetable  = false
      },
      {
        name       = "title"
        type       = "Edm.String"
        searchable = true
        filterable = true
        sortable   = true
        facetable  = false
      },
      {
        name       = "metadata_storage_name"
        type       = "Edm.String"
        searchable = true
        filterable = true
        sortable   = true
        facetable  = false
      },
      {
        name       = "metadata_storage_path"
        type       = "Edm.String"
        searchable = true
        filterable = true
        sortable   = true
        facetable  = false
      },
      {
        name       = "metadata_storage_content_md5"
        type       = "Edm.String"
        filterable = true
        sortable   = true
        facetable  = false
      },
      {
        name       = "content"
        type       = "Edm.String"
        searchable = true
        filterable = false
        sortable   = false
        facetable  = false
      },
    ],
    semantic = {
      configurations = [
        {
          name : "mmai-index-text-files-dataource",
          prioritizedFields = {
            titleField = {
              fieldName = "title"
            },
            prioritizedContentFields = [
              {
                fieldName = "content"
              }
            ],
            prioritizedKeywordsFields = []
          }
        }
      ]
    },
  }
}

# https://learn.microsoft.com/en-us/rest/api/searchservice/create-index
resource "restapi_object" "ai_search_index_mmai_text" {
  path         = "/indexes"
  query_string = "api-version=2023-10-01-Preview"
  data         = jsonencode(local.mmai_text_index_json)
  id_attribute = "name"
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text
  ]
}

locals {
  mmai_text_indexer_json = {
    name :"mmai-text-files-indexer",
    dataSourceName : "${jsondecode(restapi_object.ai_search_datasource_mmai_text.api_response).name}"
    targetIndexName : "${jsondecode(restapi_object.ai_search_index_mmai_text.api_response).name}"
    parameters : {
      configuration : {
        indexedFileNameExtensions : ".pdf,.docx,.doc,.pptx,.ppt,.xlsx,.xls,.txt,.rtf,.html,.htm,.xml,.json,.csv"
        imageAction : "none"
        dataToExtract : "contentAndMetadata"
        parsingMode: "default"
        # imageAction: "generateNormalizedImagePerPage" # "To be implementeed  for generateNormalizedImagePerPage"
      }
    }
  }
}

// https://learn.microsoft.com/en-us/rest/api/searchservice/preview-api/create-or-update-indexer
resource "restapi_object" "ai_search_indexer_mmai_text" {
  path         = "/indexers"
  query_string = "api-version=2024-07-01"
  data         = jsonencode(local.mmai_text_indexer_json)
  id_attribute = "name" # The ID field on the response
  depends_on   = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text,
    restapi_object.ai_search_index_mmai_text
  ]
}
