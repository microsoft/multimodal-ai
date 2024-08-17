locals {
  prefix = "${lower(var.prefix)}-${var.environment}"
  location = var.location
  log_analytics_name = "${local.prefix}-log001"
  application_insights_name = "${local.prefix}-appi001"

  # Storage Account
  storage_account_name = trim(replace("${local.prefix}-stg001", "-", ""), 24)
  container_name_text = "text"
  container_name_multimedia = "multimedia"
  data_files_text = fileset("${path.module}/impl/tf/data/text", "*")
  data_files_multimedia = fileset("${path.module}/impl/tf/data/text", "*")

  # Dociment Intelligence
  document_intelligence_name = "${local.prefix}-ai-docintel001"
  document_intelligence_sku = "S0"
  document_intelligence_kind = "FormRecognizer"

  # Computer Vision
  computer_vision_name = "${local.prefix}-ai-vision-001"
  coputer_vision_sku = "F0"
  coputer_vision_kind = "ComputerVision"

  # OpenAI
  opeanai_name = "${local.prefix}-ai-openai001"
  opeanai_sku = "S0"
  opeanai_kind = "OpenAI"
  gpt_model_name = "gpt-4o"
  gpt_model_version = "2024-05-13"

  # AI Search
  ai_search_name = "${local.prefix}-ai-search001"
  ai_search_sku = "standard"
  ai_search_replica_count = 1
  ai_search_index_name = "${local.prefix}-ai-search-index001"
  ai_search_indexer_name = "${local.prefix}-ai-search-indexer001"
  ai_search_datasource_name = "${local.prefix}-ai-search-datasource001"
  ai_search_skillset_name = "${local.prefix}-ai-search-skillset001"
  # ai_search_synonymmap_name = "${local.prefix}-ai-search-synonymmap001"
  # ai_search_indexer_schedule = "0 0 * * *"
  # ai_search_indexer_start_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_recurrence_interval = "Day"
  # ai_search_indexer_recurrence_count = 1
  # ai_search_indexer_recurrence_end_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_change_detection_mode = "HighWaterMark"
  # ai_search_indexer_data_deletion_detection_mode = "SoftDeleteColumn"
  # ai_search_indexer_data_deletion_detection_column = "isDeleted"
  # ai_search_indexer_data_deletion_detection_value = "true"
  # ai_search_indexer_data_deletion_detection_start_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_deletion_detection_end_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_deletion_detection_interval = "Day"
  # ai_search_indexer_data_deletion_detection_recurrence_count = 1
  # ai_search_indexer_data_deletion_detection_recurrence_end_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_deletion_detection_recurrence_interval = "Day"
  # ai_search_indexer_data_deletion_detection_recurrence_start_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_deletion_detection_recurrence_end_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_deletion_detection_recurrence_interval = "Day"
  # ai_search_indexer_data_deletion_detection_recurrence_count = 1
  # ai_search_indexer_data_deletion_detection_recurrence_start_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_deletion_detection_recurrence_end_time = "2022-01-01T00:00:00Z"
  # ai_search_indexer_data_deletion_detection_recurrence_interval = "Day"
  # ai_search_indexer_data_deletion_detection_recurrence_count = 1


}
