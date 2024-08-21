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



# locals {
#   mmai_text_skillsets_json = {
#     name : "mmai-text-files-skillset",
#     description : "mmai-text-files-skillset",
#     "skills" : [
#       # {
#       #   "@odata.type" : "#Microsoft.Skills.Text.LanguageDetectionSkill",
#       #   "inputs" : [
#       #     {
#       #       "name" : "text",
#       #       "source" : "/document/content"
#       #     }
#       #   ],
#       #   "outputs" : [
#       #     {
#       #       "name" : "languageCode",
#       #       "targetName" : "languageCode"
#       #     }
#       #   ]
#       # },
#       # {
#       #   "@odata.type" : "#Microsoft.Skills.Text.SplitSkill",
#       #   "textSplitMode" : "pages",
#       #   "maximumPageLength" : 4000,
#       #   "inputs" : [
#       #     {
#       #       "name" : "text",
#       #       "source" : "/document/content"
#       #     },
#       #     {
#       #       "name" : "languageCode",
#       #       "source" : "/document/languageCode"
#       #     }
#       #   ],
#       #   "outputs" : [
#       #     {
#       #       "name" : "textItems",
#       #       "targetName" : "pages"
#       #     }
#       #   ]
#       # },
#       # {
#       #   "@odata.type" : "#Microsoft.Skills.Text.KeyPhraseExtractionSkill",
#       #   "context" : "/document/pages/*",
#       #   "inputs" : [
#       #     {
#       #       "name" : "text",
#       #       "source" : "/document/pages/*"
#       #     },
#       #     {
#       #       "name" : "languageCode",
#       #       "source" : "/document/languageCode"
#       #     }
#       #   ],
#       #   "outputs" : [
#       #     {
#       #       "name" : "keyPhrases",
#       #       "targetName" : "keyPhrases"
#       #     }
#       #   ]
#       # },
#       {
#         "@odata.type" : "#Microsoft.Skills.Util.DocumentExtractionSkill",
#         "parsingMode" : "default",
#         "dataToExtract" : "contentAndMetadata",
#         "configuration" : {
#           "imageAction" : "generateNormalizedImages",
#           "normalizedImageMaxWidth" : 2000,
#           "normalizedImageMaxHeight" : 2000
#         },
#         "context" : "/document",
#         "inputs" : [
#           {
#             "name" : "file_data",
#             "source" : "/document/file_data"
#           }
#         ],
#         "outputs" : [
#           {
#             "name" : "content",
#             "targetName" : "extracted_content"
#           },
#           {
#             "name" : "normalized_images",
#             "targetName" : "extracted_normalized_images"
#           }
#         ]
#       }
#     ]
#   }
# }

