resource "azurerm_role_assignment" "search_service_to_opeanai_user" {
  scope                = module.aoai.cognitive_account_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.aisearchonly.search_service_identity
}

resource "azurerm_role_assignment" "search_service_to_form_recognizer" {
  scope                = module.document_intelligence.cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.aisearchonly.search_service_identity
}

resource "azurerm_role_assignment" "search_service_to_computer_vision" {
  scope                = module.computer_vision.cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.aisearchonly.search_service_identity
}

resource "azurerm_role_assignment" "search_service_to_cognitive_services_multiservice_account" {
  scope                = module.cognitive_service.cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.aisearchonly.search_service_identity
}

resource "azurerm_role_assignment" "functionapp_to_cognitive_service" {
  scope                = module.document_intelligence.cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.skills.linux_function_app_principal_id
}

resource "azurerm_role_assignment" "form_recognizer_to_storage" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.document_intelligence.cognitive_services_principal_id
}

resource "azurerm_role_assignment" "webapp_to_openai" {
  scope                = module.aoai.cognitive_account_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.backend_webapp.linux_webapp_principal_id
}

resource "azurerm_role_assignment" "webapp_to_computer_vision" {
  scope                = module.computer_vision.cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.backend_webapp.linux_webapp_principal_id
}

resource "azurerm_role_assignment" "webapp_to_search_service_index" {
  scope                = module.aisearchonly.search_service_resource_id
  role_definition_name = "Search Index Data Reader"
  principal_id         = module.backend_webapp.linux_webapp_principal_id
}

resource "azurerm_role_assignment" "webapp_to_search_service" {
  scope                = module.aisearchonly.search_service_resource_id
  role_definition_name = "Reader"
  principal_id         = module.backend_webapp.linux_webapp_principal_id
}

resource "azurerm_role_assignment" "webapp_to_storage" {
  scope                = module.storage.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.backend_webapp.linux_webapp_principal_id
}
