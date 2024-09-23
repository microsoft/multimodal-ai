module "loganalytics" {
  source = "./modules/loganalytics"

  location                     = var.location
  tags                         = local.tags
  resource_group_name          = azurerm_resource_group.resource_group.name
  log_analytics_workspace_name = var.log_analytics_workspace_name != "" ? var.log_analytics_workspace_name : "${local.abbrs.operationalInsightsWorkspaces}${local.resourceToken}"
}

module "applicationinsights" {
  source = "./modules/applicationinsights"

  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  application_insights_name  = var.application_insights_name != "" ? var.application_insights_name : "${local.abbrs.insightsComponents}${local.resourceToken}"
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
}

module "keyvault" {
  source                     = "./modules/keyvault"
  location                   = var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  key_vault_name             = var.key_vault_name != "" ? var.key_vault_name : "${local.abbrs.keyVaultVaults}${local.resourceToken}"
  key_vault_sku_name         = var.key_vault_sku_name
  #   cmk_uai_id                    = module.user_assigned_identity.user_assigned_identity_id
  #   subnet_id                     = module.network.subnet_private_endpoints_id
  #   private_dns_zone_id_key_vault = module.network.private_dns_zone_key_vault_id
}

module "storage" {
  source                          = "./modules/storage"
  location                        = var.location
  tags                            = local.tags
  resource_group_name             = azurerm_resource_group.resource_group.name
  storage_account_name            = var.storage_account_name != "" ? var.storage_account_name : substr("${local.abbrs.storageStorageAccounts}${local.resourceToken}", 0, 24)
  storage_account_container_names = [var.storage_container_name_content, var.storage_container_name_knowledgestore]
  # storage_account_share_names      = [var.storage_share_name_function_app]
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  #   subnet_id                = module.network.subnet_private_endpoints_id
  #   cmk_uai_id               = module.user_assigned_identity.user_assigned_identity_id
  #   cmk_key_vault_id         = module.key_vault.key_vault_id
  #   cmk_key_name             = module.key_vault.key_vault_cmk_name
  #   private_dns_zone_id_blob = module.network.private_dns_zone_blob_id
}


module "skills" {
  source                                            = "./modules/function"
  location                                          = var.location
  tags                                              = local.tags
  resource_group_name                               = azurerm_resource_group.resource_group.name
  subscription_id                                   = data.azurerm_client_config.current.subscription_id
  log_analytics_workspace_id                        = module.loganalytics.log_analytics_id
  function_name                                     = var.skills_service_name != "" ? var.skills_service_name : "skills-${local.resourceToken}"
  function_sku                                      = var.appservice_plan_sku
  function_application_insights_connection_string   = module.applicationinsights.application_insights_connection_string
  function_application_insights_instrumentation_key = module.applicationinsights.application_insights_instrumentation_key
  function_key_vault_id                             = module.keyvault.key_vault_id
  function_code_path                                = var.skills_service_code_path
  function_storage_account_id                       = module.storage.storage_account_id
  function_application_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    #WEBSITE_RUN_FROM_PACKAGE              = 1
    #SCM_DO_BUILD_DURING_DEPLOYMENT        = true
    #ENABLE_ORYX_BUILD                     = true
    #PYTHON_ENABLE_GUNICORN_MULTIWORKERS   = true
    PYTHONUNBUFFERED              = "1"
    DOCUMENT_INTELLIGENCE_SERVICE = module.form_recognizer.cognitive_services_name
    FUNCTIONS_EXTENSION_VERSION   = "~4"
  }
}

module "backend_webapp" {
  source                                          = "./modules/webapp"
  location                                        = var.location
  tags                                            = local.tags
  resource_group_name                             = azurerm_resource_group.resource_group.name
  subscription_id                                 = data.azurerm_client_config.current.subscription_id
  log_analytics_workspace_id                      = module.loganalytics.log_analytics_id
  webapp_name                                     = var.backend_service_name != "" ? var.backend_service_name : "backend-${local.resourceToken}"
  webapp_sku                                      = var.appservice_plan_sku
  webapp_application_insights_connection_string   = module.applicationinsights.application_insights_connection_string
  webapp_application_insights_instrumentation_key = module.applicationinsights.application_insights_instrumentation_key
  webapp_key_vault_id                             = module.keyvault.key_vault_id
  webapp_code_path                                = var.backend_service_code_path
  webapp_application_settings = {
    AZURE_STORAGE_ACCOUNT               = module.storage.storage_account_name
    AZURE_STORAGE_CONTAINER             = var.storage_container_name_content
    AZURE_SEARCH_INDEX                  = module.aisearch.search_service_index_name
    AZURE_SEARCH_SERVICE                = module.aisearch.search_service_name
    AZURE_SEARCH_SEMANTIC_RANKER        = "standard"
    AZURE_VISION_ENDPOINT               = module.computer_vision.cognitive_account_endpoint
    AZURE_SEARCH_QUERY_LANGUAGE         = "en-us"
    AZURE_SEARCH_QUERY_SPELLER          = "lexicon"
    OPENAI_HOST                         = "azure"
    AZURE_OPENAI_EMB_MODEL_NAME         = var.azure_openai_emb_model_name
    AZURE_OPENAI_EMB_DIMENSIONS         = var.azure_openai_emb_dimensions
    AZURE_OPENAI_CHATGPT_MODEL          = var.azure_openai_chatgpt_model_name
    AZURE_OPENAI_GPT4V_MODEL            = var.azure_openai_gpt4v_model_name
    AZURE_OPENAI_SERVICE                = module.aoai.cognitive_account_name
    AZURE_OPENAI_CHATGPT_DEPLOYMENT     = var.azure_openai_chatgpt_deployment_name
    AZURE_OPENAI_EMB_DEPLOYMENT         = var.azure_openai_emb_deployment_name
    AZURE_OPENAI_GPT4V_DEPLOYMENT       = var.azure_openai_gpt4v_deployment_name
    USE_VECTORS                         = true
    USE_GPT4V                           = true
    PYTHON_ENABLE_GUNICORN_MULTIWORKERS = true
    SCM_DO_BUILD_DURING_DEPLOYMENT      = true
    ENABLE_ORYX_BUILD                   = true
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = false
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = false
    PYTHONUNBUFFERED                    = "1"
  }

  webapp_build_command = <<EOT
      cd ../../frontend
      npm install
      npm run build
  EOT
}

module "aisearch" {
  source                                = "./modules/aisearch"
  location                              = var.search_service_location != "" ? var.search_service_location : var.location
  tags                                  = local.tags
  resource_group_name                   = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id            = module.loganalytics.log_analytics_id
  search_service_name                   = var.search_service_name != "" ? var.search_service_name : "${local.abbrs.searchServices}${local.resourceToken}"
  search_service_sku                    = var.search_service_sku
  semantic_search_sku                   = var.semantic_search_sku
  search_service_partition_count        = var.search_service_partition_count
  search_service_replica_count          = var.search_service_replica_count
  storage_account_id                    = module.storage.storage_account_id
  storage_container_name_content        = var.storage_container_name_content
  search_service_datasource_name        = var.search_service_datasource_name != "" ? var.search_service_datasource_name : "${local.abbrs.searchServices}ds-${local.resourceToken}"
  search_service_index_name             = var.search_service_index_name != "" ? var.search_service_index_name : "${local.abbrs.searchServices}ind-${local.resourceToken}"
  search_service_indexer_name           = var.search_service_indexer_name != "" ? var.search_service_indexer_name : "${local.abbrs.searchServices}inder-${local.resourceToken}"
  search_service_skillset_name          = var.search_service_skillset_name != "" ? var.search_service_skillset_name : "${local.abbrs.searchServices}skl-${local.resourceToken}"
  azure_openai_endpoint                 = module.aoai.cognitive_account_endpoint
  azure_openai_text_deployment_id       = var.azure_openai_text_deployment_id
  azure_openai_text_model_name          = var.azure_openai_text_model_name
  cognitive_services_endpoint           = module.cognitive_service.cognitive_account_endpoint
  cognitive_services_key                = module.cognitive_service.cognitive_services_key
  computer_vision_endpoint              = module.computer_vision.cognitive_account_endpoint
  pdf_merge_customskill_endpoint        = "https://${module.skills.linux_function_app_default_hostname}/api/pdf_text_image_merge_skill"
  knowledgestore_storage_account_id     = module.storage.storage_account_id
  storage_container_name_knowledgestore = var.storage_container_name_knowledgestore
  function_app_id                       = module.skills.linux_function_app_client_id

  depends_on = [module.aoai, module.cognitive_service, module.storage, module.skills]
}


resource "null_resource" "update_function_app_allowed_applications" {
  provisioner "local-exec" {
    command = <<EOT
      az webapp auth update --resource-group ${azurerm_resource_group.resource_group.name} --name ${module.skills.linux_function_app_name} --set identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedApplications=[${module.aisearch.managed_identity_application_id}]
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.aisearch]
}

resource "null_resource" "warmup_webapp" {
  provisioner "local-exec" {
    command = <<EOT
      curl --silent https://${module.backend_webapp.linux_webapp_default_hostname}
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.backend_webapp]
}

module "aoai" {
  source                     = "./modules/aoai"
  location                   = var.openai_service_location != "" ? var.openai_service_location : var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.openai_service_name != "" ? var.openai_service_name : "${local.abbrs.cognitiveServicesOpenAI}${local.resourceToken}"
  cognitive_service_kind     = "OpenAI"
  cognitive_service_sku      = var.openai_service_sku
  aoai_deployments           = var.aoai_deployments
}

module "cognitive_service" {
  source                     = "./modules/cognitive_service"
  location                   = var.search_service_location != "" ? var.search_service_location : var.location # must be in the same location as search service
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.cognitive_service_name != "" ? var.cognitive_service_name : "${local.abbrs.cognitiveServicesAccounts}${local.resourceToken}"
  cognitive_service_kind     = "CognitiveServices"
  cognitive_service_sku      = var.cognitive_service_sku
  local_auth_enabled         = true
}

module "form_recognizer" {
  source                     = "./modules/cognitive_service"
  location                   = var.form_recognizer_service_location != "" ? var.form_recognizer_service_location : var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.form_recognizer_name != "" ? var.form_recognizer_name : "${local.abbrs.cognitiveServicesFormRecognizer}${local.resourceToken}"
  cognitive_service_kind     = "FormRecognizer"
  cognitive_service_sku      = var.form_recognizer_sku
}

module "computer_vision" {
  source                     = "./modules/cognitive_service"
  location                   = var.computer_vision_service_location != "" ? var.computer_vision_service_location : var.location
  tags                       = local.tags
  resource_group_name        = azurerm_resource_group.resource_group.name
  log_analytics_workspace_id = module.loganalytics.log_analytics_id
  cognitive_service_name     = var.computer_vision_name != "" ? var.computer_vision_name : "${local.abbrs.cognitiveServicesComputerVision}${local.resourceToken}"
  cognitive_service_kind     = "ComputerVision"
  cognitive_service_sku      = var.computer_vision_sku
}
