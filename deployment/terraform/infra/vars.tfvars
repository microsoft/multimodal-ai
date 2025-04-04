location                         = "eastus2"
openai_service_location          = "eastus2"
search_service_location          = "eastus"
form_recognizer_service_location = "eastus"
computer_vision_service_location = "eastus"

openai_service_sku    = "S0"
computer_vision_sku   = "S1"
form_recognizer_sku   = "S0"
cognitive_service_sku = "S0"
appservice_plan_sku   = "B3"
search_service_sku    = "standard"
semantic_search_sku   = "standard"

storage_container_name_content = "docs"
#storage_container_name_knowledgestore = "knowledgestore"
storage_container_name_knowledgestore = "docs"

azure_monitor_private_link_scope_name = ""
ampls_scoped_service_appinsights      = ""
ampls_scoped_service_law              = ""

backend_service_name      = ""
skills_service_name       = ""
application_insights_name = ""
key_vault_name            = ""
key_vault_sku_name        = "standard"
search_service_name       = ""

search_service_partition_count       = 1
search_service_replica_count         = 1
search_service_datasource_name       = ""
search_service_index_name            = ""
search_service_indexer_name          = ""
search_service_skillset_name         = ""
openai_service_name                  = ""
azure_openai_text_deployment_id      = "text-embedding-ada-002"
azure_openai_text_model_name         = "text-embedding-ada-002"
cognitive_service_name               = ""
form_recognizer_name                 = ""
computer_vision_name                 = ""
storage_account_name                 = ""
azure_openai_emb_model_name          = "text-embedding-ada-002"
azure_openai_emb_deployment_name     = "text-embedding-ada-002"
azure_openai_emb_dimensions          = 1536
azure_openai_chatgpt_model_name      = "gpt-4o"
azure_openai_chatgpt_deployment_name = "gpt-4o"
azure_openai_gpt4v_model_name        = "gpt-4o"
azure_openai_gpt4v_deployment_name   = "gpt-4o"

skills_function_appregistration_client_id = ""

webapp_auth_settings = {
  enable_auth           = false
  enable_access_control = false
  server_app = {
    app_id           = ""
    app_secret_name  = ""
    app_secret_value = ""
  }
  client_app = {
    app_id           = ""
    app_secret_name  = ""
    app_secret_value = ""
  }
}
