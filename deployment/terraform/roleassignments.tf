resource "azurerm_role_assignment" "opeanai_user_to_search_service" {
  scope                = module.aoai.cognitive_account_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.aisearch.search_service_identity
}
