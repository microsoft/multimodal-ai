module "appserviceplan" {
  source = "./modules/appserviceplan"

  resource_group_name = azurerm_resource_group.mmai.name
  location            = local.location
  tags                = var.tags
  appservice_name     = local.app_service_frontend_name
  appservice_sku      = local.app_service_sku

  # site_config = {
  #   dotnet_framework_version = "v4.0"
  #   scm_type                 = "LocalGit"
  #   always_on                = true
  #   app_command_line         = "python3 -m gunicorn main:app"
  #   cors ={
  #     allowed_origins     = ["*"]
  #     support_credentials = true
  #   }
  #   linux_fx_version = "PYTHON|3.11" # Python 3.6
  # }

  # app_settings = {
  #   # USE_SPEECH_OUTPUT_BROWSER          = var.useSpeechOutputBrowser
  #   # USE_SPEECH_OUTPUT_AZURE            = var.useSpeechOutputAzure
  #   OPENAI_HOST                        = module.openai.cognitive_account_endpoint
  #   # AZURE_OPENAI_EMB_MODEL_NAME        = var.embedding.modelName
  #   # AZURE_OPENAI_EMB_DIMENSIONS        = var.embedding.dimensions
  #   # AZURE_OPENAI_CHATGPT_MODEL         = var.chatGpt.modelName
  #   # AZURE_OPENAI_GPT4V_MODEL           = var.gpt4vModelName
  #   # AZURE_OPENAI_SERVICE               = var.isAzureOpenAiHost && var.deployAzureOpenAi ? var.openAi.outputs.name : ""
  #   # AZURE_OPENAI_CHATGPT_DEPLOYMENT    = var.chatGpt.deploymentName
  #   # AZURE_OPENAI_EMB_DEPLOYMENT        = var.embedding.deploymentName
  #   # AZURE_OPENAI_GPT4V_DEPLOYMENT      = var.useGPT4V ? var.gpt4vDeploymentName : ""
  #   # AZURE_OPENAI_API_VERSION           = var.azureOpenAiApiVersion
  #   # AZURE_OPENAI_API_KEY_OVERRIDE      = var.azureOpenAiApiKey
  #   # AZURE_OPENAI_CUSTOM_URL            = var.azureOpenAiCustomUrl
  #   # OPENAI_API_KEY                     = var.openAiApiKey
  #   # OPENAI_ORGANIZATION                = var.openAiApiOrganization
  #   # AZURE_USE_AUTHENTICATION           = var.useAuthentication
  #   # AZURE_ENFORCE_ACCESS_CONTROL       = var.enforceAccessControl
  #   # AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS = var.enableGlobalDocuments
  #   # AZURE_ENABLE_UNAUTHENTICATED_ACCESS = var.enableUnauthenticatedAccess
  #   # AZURE_SERVER_APP_ID                = var.serverAppId
  #   # AZURE_SERVER_APP_SECRET            = var.serverAppSecret
  #   # AZURE_CLIENT_APP_ID                = var.clientAppId
  #   # AZURE_CLIENT_APP_SECRET            = var.clientAppSecret
  #   # AZURE_TENANT_ID                    = var.tenantId
  #   # AZURE_AUTH_TENANT_ID               = var.tenantIdForAuth
  #   # AZURE_AUTHENTICATION_ISSUER_URI    = var.authenticationIssuerUri
  #   # ALLOWED_ORIGIN                     = var.allowedOrigin
  #   # USE_VECTORS                        = var.useVectors
  #   # USE_GPT4V                          = var.useGPT4V
  #   # USE_USER_UPLOAD                    = var.useUserUpload
  #   # AZURE_USERSTORAGE_ACCOUNT          = var.useUserUpload ? var.userStorage.outputs.name : ""
  #   # AZURE_USERSTORAGE_CONTAINER        = var.useUserUpload ? var.userStorageContainerName : ""
  #   # AZURE_DOCUMENTINTELLIGENCE_SERVICE = var.documentIntelligence.outputs.name
  #   # USE_LOCAL_PDF_PARSER               = var.useLocalPdfParser
  #   # USE_LOCAL_HTML_PARSER              = var.useLocalHtmlParser
  # }
}
