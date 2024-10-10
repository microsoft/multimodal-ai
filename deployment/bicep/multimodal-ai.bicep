targetScope = 'subscription'

// Parameters
@sys.description('Prefix for the resources to be created')
@maxLength(8)
param prefix string

@sys.description('Azure Region where the resources will be created.')
param location string

// Azure OpenAI Parameters
param aoaiKind string
param aoaiSku string
@sys.description('Azure OpenAI deployments to be created.')
param aoaiDeployments array = []

// Azure Cognitive Services Parameters
param cogsvcSku string
param cogsvcKind string

// Azure AI Search Parameters
param aiSearchLocation string
param aiSearchSku string
param aiSearchCapacity int
param aiSearchSemanticSearch string

// Azure AI Vision Parameters
param aiVisionKind string
param aiVisionSku string

@sys.description('Azure Region where AI Vision will be deployed. Supported for AI Vision multimodal embeddings API 2024-02-01 is limited to certain regions.')
@sys.allowed([
  'eastus'
  'westus'
  'westus2'
  'francecentral'
  'northeurope'
  'westeurope'
  'swedencentral'
  'switzerlandnorth'
  'australiaeast'
  'southeastasia'
  'koreacentral'
  'japaneast'
])
param aiVisionlocation string

// Document Intelligence Parameters
param docIntelKind string
param docIntelSku string

@sys.description('Azure Region where Document Intelligence will be deployed. Support for API 2024-07-31-preview is limited to certain regions.')
@sys.allowed([
  'eastus'
  'westus2'
  'westeurope'
  'northcentralus'
])
param docIntelLocation string

@sys.description('Specifies the container name to be created in the storage account for documents.')
param storageAccountDocsContainerName string

@sys.description('Specifies the tags which will be applied to all resources.')
param tags object = {}

@sys.description('Specifies the text embedding model to use in Azure OpenAI.')
param aoaiTextEmbeddingModel string

@sys.description('Specifies the chat model to use in Azure OpenAI.')
param aoaiChatModel string

@sys.description('Specifies the Vision model to use in Azure OpenAI.')
param aoaiVisionModel string

@sys.description('App Service Plan Sku')
param appServiceSkuName string

@sys.description('ClientId of an existing Microsoft Entra ID App registration to enable authentication for the Azure Function App.')
param functionAppClientId string

@secure()
@sys.description('Auth settings for the web app.')
param authSettings object

// Variables
var authenticationIssuerUri = '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'
var locationNormalized = toLower(location)
var prefixNormalized = toLower(prefix)

var resourceGroupNames = {
  ai: '${prefixNormalized}-${locationNormalized}-ai-rg'
  storage: '${prefixNormalized}-${locationNormalized}-storage-rg'
  monitoring: '${prefixNormalized}-${locationNormalized}-monitoring-rg'
  apps: '${prefixNormalized}-${locationNormalized}-apps-rg'
}

var resourceNames = {
  aiVision: '${prefixNormalized}-${locationNormalized}-ai-vision'
  azureOpenAI: '${prefixNormalized}-${locationNormalized}-aoai'
  documentIntelligence: '${prefixNormalized}-${locationNormalized}-docintel'
  aiSearch: '${prefixNormalized}-${locationNormalized}-aisearch'
  cognitiveServices: '${prefixNormalized}-${locationNormalized}-cogsvc'
  storageAccount: take('${prefixNormalized}${locationNormalized}stg',23)
  aiSearchDeploymentScriptIdentity: '${prefixNormalized}-${locationNormalized}-aisearch-depscript-umi'
  aiSearchDocsDataSourceName: '${storageAccountDocsContainerName}-datasource'
  appServicePlan: '${prefixNormalized}-${locationNormalized}-appserviceplan'
  functionApp: '${prefixNormalized}-${locationNormalized}-functionapp'
  functionStorageAccountName: take('${prefixNormalized}${locationNormalized}functionstg',23)
  logAnalyticsWorkspaceName: '${prefixNormalized}-${locationNormalized}-loganalytics'
  appInsightsName: '${prefixNormalized}-${locationNormalized}-appinsights'
  aiSearchIndexName: '${prefixNormalized}index'
  aiSearchSkillsetName: '${prefixNormalized}-skillset'
  webAppServicePlanName: '${prefixNormalized}-${locationNormalized}-webapp-svcplan'
  webAppName: '${prefixNormalized}-${locationNormalized}-webapp'
  keyVaultName: '${prefixNormalized}-${locationNormalized}-kv'
}

var appServicePlan = {
  tier: 'Standard'
  name: resourceNames.appServicePlan
  size: 'S1'
  family: 'S'
  capacity: 1
}

var logAnalyticsSettings = {
  sku: 'PerGB2018'
  retentionInDays: 30
}

// Resources

// Resource Group AI
module resourceGroupAI './modules/resourceGroup/resourceGroup.bicep' = {
  name: 'modResourceGroupAI'
  params: {
    location: location
    resourceGroupName: resourceGroupNames.ai
    tags: tags
  }
}

// Resource Group Storage
module resourceGroupStorage './modules/resourceGroup/resourceGroup.bicep' = {
  name: 'modResourceGroupStorage'
  params: {
    location: location
    resourceGroupName: resourceGroupNames.storage
    tags: tags
  }
}

// Resource Group Monitoring
module resourceGroupMonitoring './modules/resourceGroup/resourceGroup.bicep' = {
  name: 'modResourceGroupMonitoring'
  params: {
    location: location
    resourceGroupName: resourceGroupNames.monitoring
    tags: tags
  }
}

module resourceGroupApps './modules/resourceGroup/resourceGroup.bicep' = {
  name: 'modResourceGroupApps'
  params: {
    location: location
    resourceGroupName: resourceGroupNames.apps
    tags: tags
  }
}

// Azure Resources

// Azure OpenAI
module azureOpenAI 'modules/cognitiveServices/cognitiveServices.bicep' = {
  name: 'modAzureOpenAI'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
  ]
  params: {
    location: location
    name: resourceNames.azureOpenAI
    sku: aoaiSku
    kind: aoaiKind
    tags: tags
  }
}

//Azure OpenAI Model Deployments
@batchSize(1)
module azureOpenAIModelDeployments 'modules/aoai/aoaiDeployment.bicep' = [for deployment in aoaiDeployments: {
  name: 'aoai-deployment-${deployment.name}'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    azureOpenAI
  ]
  params: {
    name: deployment.name
    version: deployment.model.version
    format: deployment.model.format
    capacity: deployment.sku.capacity
    cognitiveServicesAccountId: azureOpenAI.outputs.cognitiveServicesAccountId
  }
}]

// Azure Cognitive Services. It must be deployed in the same Azure region as AI Search.
module azureCognitiveServices 'modules/cognitiveServices/cognitiveServices.bicep' = {
  name: 'modAzureCognitiveServices'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
  ]
  params: {
    location: aiSearchLocation
    name: resourceNames.cognitiveServices
    sku: cogsvcSku
    kind: cogsvcKind
    tags: tags
  }
}

// Azure AI Vision
module azureAIVision 'modules/cognitiveServices/cognitiveServices.bicep' = {
  name: 'modAzureAIVision'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
  ]
  params: {
    location: aiVisionlocation
    name: resourceNames.aiVision
    sku: aiVisionSku
    kind: aiVisionKind
    tags: tags
  }
}

// Azure Document Intelligence
module documentIntelligence 'modules/cognitiveServices/cognitiveServices.bicep' = {
  name: 'modDocumentIntelligence'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
  ]
  params: {
    location: docIntelLocation
    name: resourceNames.documentIntelligence
    sku: docIntelSku
    kind: docIntelKind
    tags: tags
  }
}

// Storage Account
module storageAccount 'modules/storage/storageAccount.bicep' = {
  name: 'modStorageAccount'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn: [
    resourceGroupStorage
  ]
  params: {
    storageAccountName: resourceNames.storageAccount
    containerName: storageAccountDocsContainerName
    location: location
    tags: tags
  }
}

// AI Search Deployment Script Identity
module deploymentScriptIdentity 'modules/managedIdentities/managedIdentity.bicep' = {
  name: 'modDeploymentScriptIdentity'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
  ]
  params: {
    name: resourceNames.aiSearchDeploymentScriptIdentity
    location: location
  }
}

// AI Search
module aiSearch 'modules/aiSearch/aiSearch.bicep' = {
  name: 'modAiSearch'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
  ]
  params: {
    location: aiSearchLocation
    searchName: resourceNames.aiSearch
    skuName: aiSearchSku
    skuCapacity: aiSearchCapacity
    semanticSearch: aiSearchSemanticSearch
    tags: tags
  }
}

// Log Analytics Workspace
module logAnalytics 'modules/logAnalytics/logAnalytics.bicep' = {
  name: 'modLogAnalytics'
  scope: resourceGroup(resourceGroupNames.monitoring)
  dependsOn: [
    resourceGroupMonitoring
  ]
  params: {
    location: location
    logAnalyticsWorkspaceName: resourceNames.logAnalyticsWorkspaceName
    logAnalyticsSku: logAnalyticsSettings.sku
    logAnalyticsRetentionInDays: logAnalyticsSettings.retentionInDays
    tags: tags
  }
}

// App Insights
module appInsights 'modules/appInsights/appInsights.bicep' = {
  name: 'modAppInsights'
  scope: resourceGroup(resourceGroupNames.monitoring)
  dependsOn: [
    logAnalytics
  ]
  params: {
    location: location
    appInsightsName: resourceNames.appInsightsName
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    tags: tags
  }
}

// Role Assignments
module deploymentScriptIdentityRoleAssignmentAI 'modules/rbac/roleAssignment-deploymentScriptIdentity-ai.bicep' = {
  name: 'modDeploymentScriptIdentityRoleAssignmentAI'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    deploymentScriptIdentity
  ]
  params: {
    aiSearchId: aiSearch.outputs.searchResourceId
    managedIdentityPrincipalId: deploymentScriptIdentity.outputs.managedIdentityPrincipalId
  }
}

module aiSearchRoleAssignmentAI 'modules/rbac/roleAssignment-searchService-ai.bicep' = {
  name: 'modAISearchRoleAssignmentAI'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    azureOpenAI
    azureAIVision
    documentIntelligence
  ]
  params: {
    azureOpenAIResourceId: azureOpenAI.outputs.cognitiveServicesAccountId
    azureAIVisionResourceId: azureAIVision.outputs.cognitiveServicesAccountId
    documentIntelligenceResourceId: documentIntelligence.outputs.cognitiveServicesAccountId
    managedIdentityPrincipalId: aiSearch.outputs.searchResourcePrincipalId
  }
}

module functionRoleAssignmentAI 'modules/rbac/roleAssignment-function-ai.bicep' = {
  name: 'modFunctionRoleAssignmentAI'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    azureFunction
    documentIntelligence
  ]
  params: {
    documentIntelligenceResourceId : documentIntelligence.outputs.cognitiveServicesAccountId
    managedIdentityPrincipalId: azureFunction.outputs.functionAppPrincipalId
  }
}

module aiSearchRoleAssignmentStorage 'modules/rbac/roleAssignment-searchService-storage.bicep' = {
  name: 'modAISearchRoleAssignmentStorage'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn: [
    storageAccount
    aiSearch
  ]
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    managedIdentityPrincipalId: aiSearch.outputs.searchResourcePrincipalId
  }
}

module docIntelligenceRoleAssignmentStorage 'modules/rbac/roleAssignment-docIntelligence-storage.bicep' = {
  name: 'modDocIntelligenceRoleAssignmentStorage'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn:[
    storageAccount
    documentIntelligence
  ]
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    managedIdentityPrincipalId: documentIntelligence.outputs.cognitiveServicesPrincipalId
  }
}

module appServiceRoleAssignmentAI 'modules/rbac/roleAssignment-appService-ai.bicep' = {
  name: 'modAppServiceRoleAssignmentAI'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    webApp
    aiSearch
    azureOpenAI
    azureAIVision
  ]
  params: {
    azureOpenAIResourceId: azureOpenAI.outputs.cognitiveServicesAccountId
    azureAIVisionResourceId: azureAIVision.outputs.cognitiveServicesAccountId
    azureAISearchResourceId: aiSearch.outputs.searchResourceId
    managedIdentityPrincipalId: webApp.outputs.identityPrincipalId
  }
}

module appServiceRoleAssignmentStorage 'modules/rbac/roleAssignment-appService-storage.bicep' = {
  name: 'modAppServiceRoleAssignmentStorage'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn: [
    webApp
    storageAccount
    keyVault
  ]
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    keyVaultName: keyVault.outputs.name
    managedIdentityPrincipalId: webApp.outputs.identityPrincipalId
  }
}

module azureFunctionAppRegistration 'modules/appRegistration/appRegistration.bicep' = if (empty(functionAppClientId)) {
  name: 'modAzureFunctionAppRegistration'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn:[
    resourceGroupApps
  ]
  params: {
    clientAppName: '${prefixNormalized}-custom-skills-functionapp'
  }
}

// Azure Function App for AI Search Custom Skills

module aiSearchManagedIdentity 'modules/aiSearch/aiSearch-managedIdentity.bicep' = {
  name: 'modAiSearchManagedIdentity'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn:[
    aiSearch
  ]
  params: {
    searchResourceName: aiSearch.outputs.searchResourceName
  }
}

module azureFunction 'modules/function/function.bicep' = {
  name: 'modAzureFunction'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn: [
    resourceGroupAI
    storageAccount
    logAnalytics
    appInsights
    documentIntelligence
    docIntelligenceRoleAssignmentStorage
    azureFunctionAppRegistration
    aiSearchManagedIdentity
  ]
  params: {
    location: location
    tags: tags
    applicationInsightsName: appInsights.outputs.appInsightsResourceName
    applicationInsightsResourceGroup: resourceGroupNames.monitoring
    appServiceCapacity: appServicePlan.capacity
    appServiceFamily: appServicePlan.family
    appServiceName: appServicePlan.name
    appServiceSize: appServicePlan.size
    appServiceTier: appServicePlan.tier
    azureFunctionName: resourceNames.functionApp
    azureFunctionStorageName: resourceNames.functionStorageAccountName
    logAnalyticsWorkspaceid: logAnalytics.outputs.logAnalyticsWorkspaceId
    clientAppId: empty(functionAppClientId) ? azureFunctionAppRegistration.outputs.appId : functionAppClientId
    documentIntelligenceServiceInstanceName: documentIntelligence.outputs.cognitiveServicesAccountName
    authenticationIssuerUri: authenticationIssuerUri
    allowedApplications: [
      aiSearchManagedIdentity.outputs.appId
    ]
  }
}

module keyVault './modules/keyvault/keyvault.bicep' = {
  name: 'modKeyVault'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn:[
    resourceGroupStorage
  ]
  params: {
    keyVaultName: resourceNames.keyVaultName
    location: location
  }
}

module serverAppKeyVaultSecret './modules/keyvault/keyvault-secret.bicep' = if (!empty(authSettings.serverApp.appSecret)) {
  name: 'modServerAppKeyVaultSecret'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn:[
    keyVault
  ]
  params: {
    keyVaultName: resourceNames.keyVaultName
    secretName: authSettings.serverApp.appSecretName
    secretValue: authSettings.serverApp.appSecret
  }
}

module clientAppKeyVaultSecret './modules/keyvault/keyvault-secret.bicep' = if (!empty(authSettings.clientApp.appSecret)) {
  name: 'modClientAppKeyVaultSecret'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn:[
    keyVault
  ]
  params: {
    keyVaultName: resourceNames.keyVaultName
    secretName: authSettings.clientApp.appSecretName
    secretValue: authSettings.clientApp.appSecret
  }
}

// Azure Web App
module webAppServicePlan 'modules/appService/appServicePlan.bicep' = {
  name: 'modWebAppServicePlan'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn:[
    resourceGroupApps
  ]
  params: {
    name: resourceNames.webAppServicePlanName
    location: location
    tags: tags
    sku: {
      name: appServiceSkuName
      capacity: 1
    }
    kind: 'linux'
  }
}

module webApp 'modules/appService/appService.bicep' = {
  name: 'modWebApp'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn: [
    resourceGroupApps
    webAppServicePlan
    appInsights
  ]
  params: {
    name: resourceNames.webAppName
    location: location
    tags: tags
    applicationInsightsName: appInsights.outputs.appInsightsResourceName
    applicationInsightsResourceGroup: resourceGroupNames.monitoring
    appServicePlanId: webAppServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.11'
    appCommandLine: 'python3 -m gunicorn main:app'
    use32BitWorkerProcess: appServiceSkuName == 'F1'
    alwaysOn: appServiceSkuName != 'F1'
    authSettings: {
      enableAuth: authSettings.enableAuth
      clientAppId: authSettings.clientApp.appId
      serverAppId: authSettings.serverApp.appId
      clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
      authenticationIssuerUri: authenticationIssuerUri
      allowedApplications: [
        authSettings.clientApp.appId
      ]
    }
    appSettings: {
      AZURE_STORAGE_ACCOUNT: resourceNames.storageAccount
      AZURE_STORAGE_CONTAINER: storageAccountDocsContainerName
      AZURE_SEARCH_INDEX: resourceNames.aiSearchIndexName
      AZURE_SEARCH_SERVICE: resourceNames.aiSearch
      AZURE_SEARCH_SEMANTIC_RANKER: 'standard'
      AZURE_VISION_ENDPOINT: 'https://${resourceNames.aiVision}.cognitiveservices.azure.com'
      AZURE_SEARCH_QUERY_LANGUAGE: 'en-us'
      AZURE_SEARCH_QUERY_SPELLER: 'lexicon'
      OPENAI_HOST: 'azure'
      AZURE_OPENAI_EMB_MODEL_NAME: aoaiTextEmbeddingModel
      AZURE_OPENAI_EMB_DIMENSIONS: 1536
      AZURE_OPENAI_CHATGPT_MODEL: aoaiChatModel
      AZURE_OPENAI_GPT4V_MODEL: aoaiVisionModel
      AZURE_OPENAI_SERVICE: resourceNames.azureOpenAI
      AZURE_OPENAI_CHATGPT_DEPLOYMENT: first(filter(aoaiDeployments, deployment => deployment.name == aoaiChatModel)).name
      AZURE_OPENAI_EMB_DEPLOYMENT: first(filter(aoaiDeployments, deployment => deployment.name == aoaiTextEmbeddingModel)).name
      AZURE_OPENAI_GPT4V_DEPLOYMENT: first(filter(aoaiDeployments, deployment => deployment.name == aoaiVisionModel)).name
      USE_VECTORS: true
      USE_GPT4V: true
      PYTHON_ENABLE_GUNICORN_MULTIWORKERS: true
      SCM_DO_BUILD_DURING_DEPLOYMENT: true
      ENABLE_ORYX_BUILD: true
      AZURE_USE_AUTHENTICATION: authSettings.enableAuth
      AZURE_SERVER_APP_ID: authSettings.serverApp.appId
      AZURE_SERVER_APP_SECRET: '@Microsoft.KeyVault(VaultName=${resourceNames.keyVaultName};SecretName=${authSettings.serverApp.appSecretName})'
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=${resourceNames.keyVaultName};SecretName=${authSettings.clientApp.appSecretName})'
      AZURE_CLIENT_APP_ID: authSettings.clientApp.appId
      AZURE_AUTH_TENANT_ID: tenant().tenantId
      AZURE_ENFORCE_ACCESS_CONTROL: authSettings.enableAccessControl
      AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS: true
      AZURE_ENABLE_UNAUTHENTICATED_ACCESS: !authSettings.enableAuth
      AZURE_AUTHENTICATION_ISSUER_URI: authenticationIssuerUri
    }
  }
}

// Azure AI Search Configuration

// Create data source
module aiSearchDataSource 'modules/aiSearch/aiSearch-datasource.bicep' = {
  name: 'modAiSearchDataSource'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    storageAccount
    deploymentScriptIdentityRoleAssignmentAI
    aiSearchRoleAssignmentAI
    aiSearchRoleAssignmentStorage
  ]
  params: {
    location: location
    dataSourceName: resourceNames.aiSearchDocsDataSourceName
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    storageAccountResourceId: storageAccount.outputs.storageAccountId
    containerName: storageAccountDocsContainerName
    managedIdentityId: deploymentScriptIdentity.outputs.managedIdentityId
  }
}

// Create AI Search index
module aiSearchIndex 'modules/aiSearch/aiSearch-index.bicep' = {
  name: 'modAiSearchIndex'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    deploymentScriptIdentityRoleAssignmentAI
    aiSearchRoleAssignmentAI
    aiSearchRoleAssignmentStorage
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: resourceNames.aiSearchIndexName
    azureOpenAIEndpoint: 'https://${azureOpenAI.outputs.cognitiveServicesAccountName}.openai.azure.com/'
    azureOpenAITextModelName: aoaiTextEmbeddingModel
    cognitiveServicesEndpoint: 'https://${azureAIVision.outputs.cognitiveServicesAccountName}.cognitiveservices.azure.com'
    managedIdentityId: deploymentScriptIdentity.outputs.managedIdentityId
  }
}

// Create AI Search skillset
module aiSearchSkillset 'modules/aiSearch/aiSearch-skillset.bicep' = {
  name: 'modAiSearchSkillset'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    aiSearchIndex
    storageAccount
    azureCognitiveServices
    azureOpenAI
    azureFunction
    deploymentScriptIdentityRoleAssignmentAI
    aiSearchRoleAssignmentAI
    aiSearchRoleAssignmentStorage
    functionRoleAssignmentAI
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: resourceNames.aiSearchIndexName
    skillsetName: resourceNames.aiSearchSkillsetName
    azureOpenAIEndpoint: 'https://${azureOpenAI.outputs.cognitiveServicesAccountName}.openai.azure.com/'
    azureOpenAITextModelName: aoaiTextEmbeddingModel
    knowledgeStoreStorageResourceUri: 'ResourceId=${storageAccount.outputs.storageAccountId}'
    knowledgeStoreStorageContainer: storageAccountDocsContainerName
    pdfMergeCustomSkillEndpoint: azureFunction.outputs.pdfTextImageMergeSkillEndpoint
    aadAppId: empty(functionAppClientId) ? azureFunctionAppRegistration.outputs.appId : functionAppClientId
    cognitiveServicesAccountId: azureCognitiveServices.outputs.cognitiveServicesAccountId
    managedIdentityId: deploymentScriptIdentity.outputs.managedIdentityId
  }
}

// Create AI Searcher indexer
module aiSearchIndexer 'modules/aiSearch/aiSearch-indexer.bicep' = {
  name: 'modAiSearchIndexer'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    aiSearchIndex
    aiSearchSkillset
    deploymentScriptIdentityRoleAssignmentAI
    aiSearchRoleAssignmentAI
    aiSearchRoleAssignmentStorage
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: resourceNames.aiSearchIndexName
    skillsetName : resourceNames.aiSearchSkillsetName
    dataSourceName: resourceNames.aiSearchDocsDataSourceName
    managedIdentityId: deploymentScriptIdentity.outputs.managedIdentityId
  }
}

output appsResourceGroup string = resourceGroupNames.apps
output webAppName string = webApp.outputs.name
output webAppUri string = webApp.outputs.uri
output functionAppName string = azureFunction.outputs.functionAppName
