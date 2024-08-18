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
  id_attribute = "name"
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
  mmai_text_skillsets_json = {
    name : "mmai-text-files-skillset",
    description : "mmai-text-files-skillset",
    "skills" : [
      # {
      #   "@odata.type" : "#Microsoft.Skills.Text.LanguageDetectionSkill",
      #   "inputs" : [
      #     {
      #       "name" : "text",
      #       "source" : "/document/content"
      #     }
      #   ],
      #   "outputs" : [
      #     {
      #       "name" : "languageCode",
      #       "targetName" : "languageCode"
      #     }
      #   ]
      # },
      # {
      #   "@odata.type" : "#Microsoft.Skills.Text.SplitSkill",
      #   "textSplitMode" : "pages",
      #   "maximumPageLength" : 4000,
      #   "inputs" : [
      #     {
      #       "name" : "text",
      #       "source" : "/document/content"
      #     },
      #     {
      #       "name" : "languageCode",
      #       "source" : "/document/languageCode"
      #     }
      #   ],
      #   "outputs" : [
      #     {
      #       "name" : "textItems",
      #       "targetName" : "pages"
      #     }
      #   ]
      # },
      # {
      #   "@odata.type" : "#Microsoft.Skills.Text.KeyPhraseExtractionSkill",
      #   "context" : "/document/pages/*",
      #   "inputs" : [
      #     {
      #       "name" : "text",
      #       "source" : "/document/pages/*"
      #     },
      #     {
      #       "name" : "languageCode",
      #       "source" : "/document/languageCode"
      #     }
      #   ],
      #   "outputs" : [
      #     {
      #       "name" : "keyPhrases",
      #       "targetName" : "keyPhrases"
      #     }
      #   ]
      # },
      {
        "@odata.type" : "#Microsoft.Skills.Util.DocumentExtractionSkill",
        "parsingMode" : "default",
        "dataToExtract" : "contentAndMetadata",
        "configuration" : {
          "imageAction" : "generateNormalizedImages",
          "normalizedImageMaxWidth" : 2000,
          "normalizedImageMaxHeight" : 2000
        },
        "context" : "/document",
        "inputs" : [
          {
            "name" : "file_data",
            "source" : "/document/file_data"
          }
        ],
        "outputs" : [
          {
            "name" : "content",
            "targetName" : "extracted_content"
          },
          {
            "name" : "normalized_images",
            "targetName" : "extracted_normalized_images"
          }
        ]
      }
    ]
  }
}

# Create
// https://learn.microsoft.com/en-us/rest/api/searchservice/preview-api/create-or-update-indexer
resource "restapi_object" "ai_search_skillsets_mmai_text" {
  path         = "/skillsets"
  query_string = "api-version=2024-07-01"
  data         = jsonencode(local.mmai_text_skillsets_json)
  id_attribute = "name" # The ID field on the response
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text,
    restapi_object.ai_search_index_mmai_text
  ]
}

locals {
  indexer_json = templatefile("${path.module}/lib/indexer_template.json", {
    indexer_Name =  "mmai-text-files-indexer"
    dataSourceName = jsondecode(restapi_object.ai_search_datasource_mmai_text.api_response).name
    targetIndexName = jsondecode(restapi_object.ai_search_index_mmai_text.api_response).name
    skillsetName = jsondecode(restapi_object.ai_search_skillsets_mmai_text.api_response).name
  })
}

// https://learn.microsoft.com/en-us/rest/api/searchservice/preview-api/create-or-update-indexer
resource "restapi_object" "ai_search_indexer_mmai_text" {
  path         = "/indexers"
  query_string = "api-version=2024-07-01"
  data         = local.indexer_json
  id_attribute = "name" # The ID field on the response
  depends_on = [
    module.ai_search,
    restapi_object.ai_search_datasource_mmai_text,
    restapi_object.ai_search_index_mmai_text,
    restapi_object.ai_search_skillsets_mmai_text,
  ]
}

# # Reset - https://learn.microsoft.com/en-us/rest/api/searchservice/indexers/reset?view=rest-searchservice-2024-07-01&tabs=HTTP
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

#  Reset - https://learn.microsoft.com/en-us/rest/api/searchservice/indexers/reset?view=rest-searchservice-2024-07-01&tabs=HTTP
data "http" "ai_search_indexer_mmai_text_run" {
  url    = "https://${local.ai_search_name}.search.windows.net/indexers/${jsondecode(restapi_object.ai_search_indexer_mmai_text.api_response).name}/run?api-version=2024-07-01"
  method = "POST"
  request_headers = {
    "api-key"      = module.ai_search.search_service_key
    "Content-Type" = "application/json"
  }
  depends_on = [
    data.http.ai_search_indexer_mmai_text_reset
  ]
}