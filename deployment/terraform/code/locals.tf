locals {
  prefix                    = "${lower(var.prefix)}-${var.environment}"
  location                  = var.location
  log_analytics_name        = "${local.prefix}-log001"
  application_insights_name = "${local.prefix}-appi001"

  # Storage Account
  storage_account_name      = trim(replace("${local.prefix}-stg001", "-", ""), 24)
  container_name_text       = "text"
  container_name_multimedia = "multimedia"
  data_files_text           = "${path.module}/../data/text"
  data_files_multimedia     = "${path.module}/../data/multimedia"

  # Dociment Intelligence
  document_intelligence_name = "${local.prefix}-ai-docintel001"
  document_intelligence_sku  = "S0"
  document_intelligence_kind = "FormRecognizer"

  # Computer Vision
  computer_vision_name = "${local.prefix}-ai-vision-001"
  coputer_vision_sku   = "F0"
  coputer_vision_kind  = "ComputerVision"

  # OpenAI
  opeanai_name      = "${local.prefix}-ai-openai001"
  opeanai_sku       = "S0"
  opeanai_kind      = "OpenAI"

  chat_model    = "gpt-35-turbo"
  chat_deployment = "chat"
  chat_version = "0301"
  chat_capacity = 30

  embedding_model    = "text-embedding-ada-002"
  embedding_deployment = "embedding"
  embedding_capacity = 30
  embedding_version = "2"

  gpt4v_model    = "gpt-4o"
  gpt4v_deployment = "gpt4v"
  gpt4v_capacity = 10

  # conginative services
  cognitiveservice_name = "${local.prefix}-cognitive-service-001"
  cognitiveservice_sku  = "S0"
  cognitiveservice_kind = "CognitiveServices"


  # AI Search
  ai_search_name            = "${local.prefix}-ai-search001"
  ai_search_sku             = "standard"
  ai_search_replica_count   = 1
  ai_search_index_name      = "${local.prefix}-ai-search-index001"
  ai_search_indexer_name    = "${local.prefix}-ai-search-indexer001"
  ai_search_datasource_name = "${local.prefix}-ai-search-datasource001"
  ai_search_skillset_name   = "${local.prefix}-ai-search-skillset001"

  # App service Frontend
  app_service_backend_name  = "${local.prefix}-app-service-back002"
  app_service_plan_name     = "${local.prefix}-app-service-plan"
  app_service_sku           = "P3mv3"

}