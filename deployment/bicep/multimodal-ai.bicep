import * as inputSchema from './input-types.bicep'

targetScope = 'subscription'

@sys.description('Prefix for the resources to be created')
@maxLength(8)
param prefix string

@sys.description('Azure Region where the resources will be created.')
param location string

@sys.description('Specifies the tags which will be applied to all resources.')
param tags object = {}

@sys.description('Specifies the container name to be created in the storage account for documents.')
param storageAccountDocsContainerName string

@sys.description('Deployment configuration for Azure OpenAI.')
param azureOpenAiConfig inputSchema.azureOpenAiConfig

@sys.description('Deployment configuration for Azure AI Vision.')
param aiVisionConfig inputSchema.cognitiveServicesConfig

@sys.description('Deployment configuration for Document Intelligence Service.')
param docIntelConfig inputSchema.cognitiveServicesConfig

@sys.description('Deployment configuration for Cognitive Services Account.')
param cognitiveServicesConfig inputSchema.cognitiveServicesConfig

@sys.description('Deployment configuration for Azure AI Search.')
param aiSearchConfig inputSchema.aiSearchConfig

param webAppServicePlanConfig inputSchema.appServicePlanConfig

param functionAppServicePlanConfig inputSchema.appServicePlanConfig

@sys.description('Configuration for the Azure Function App registration.')
param functionAppEntraIdRegistration inputSchema.appRegistration

@sys.description('Auth settings for the web app.')
param webAppAuthSettings inputSchema.webAppAuthSettings

@sys.description('Deployment configuration for Log Analytics.')
param logAnalyticsConfig inputSchema.logAnalyticsConfig

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
  functionAppServicePlanName: '${prefixNormalized}-${locationNormalized}-functionapp-svcplan'
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
    location: azureOpenAiConfig.cognitiveServicesConfig.location
    name: resourceNames.azureOpenAI
    sku: azureOpenAiConfig.cognitiveServicesConfig.sku
    kind: azureOpenAiConfig.cognitiveServicesConfig.kind
    tags: tags
  }
}

//Azure OpenAI Model Deployments
@batchSize(1)
module azureOpenAIModelDeployments 'modules/aoai/aoaiDeployment.bicep' = [for deployment in azureOpenAiConfig.deployments: {
  name: 'aoai-deployment-${deployment.name}'
  scope: resourceGroup(resourceGroupNames.ai)
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
    location: cognitiveServicesConfig.location
    name: resourceNames.cognitiveServices
    sku: cognitiveServicesConfig.sku
    kind: cognitiveServicesConfig.kind
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
    location: aiVisionConfig.location
    name: resourceNames.aiVision
    sku: aiVisionConfig.sku
    kind: aiVisionConfig.kind
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
    location: docIntelConfig.locationOfdocIntelligenceWithApi2024_07_31_preview ?? docIntelConfig.location
    name: resourceNames.documentIntelligence
    sku: docIntelConfig.sku
    kind: docIntelConfig.kind
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
    location: aiSearchConfig.location
    searchName: resourceNames.aiSearch
    skuName: aiSearchConfig.sku
    skuCapacity: aiSearchConfig.capacity
    semanticSearch: aiSearchConfig.semanticSearchSku
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
    logAnalyticsSku: logAnalyticsConfig.sku
    logAnalyticsRetentionInDays: logAnalyticsConfig.retentionInDays
    tags: tags
  }
}

// App Insights
module appInsights 'modules/appInsights/appInsights.bicep' = {
  name: 'modAppInsights'
  scope: resourceGroup(resourceGroupNames.monitoring)
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
  params: {
    aiSearchId: aiSearch.outputs.searchResourceId
    managedIdentityPrincipalId: deploymentScriptIdentity.outputs.managedIdentityPrincipalId
  }
}

module aiSearchRoleAssignmentAI 'modules/rbac/roleAssignment-searchService-ai.bicep' = {
  name: 'modAISearchRoleAssignmentAI'
  scope: resourceGroup(resourceGroupNames.ai)
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
  params: {
    documentIntelligenceResourceId : documentIntelligence.outputs.cognitiveServicesAccountId
    managedIdentityPrincipalId: azureFunction.outputs.functionAppPrincipalId
  }
}

module aiSearchRoleAssignmentStorage 'modules/rbac/roleAssignment-searchService-storage.bicep' = {
  name: 'modAISearchRoleAssignmentStorage'
  scope: resourceGroup(resourceGroupNames.storage)
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    managedIdentityPrincipalId: aiSearch.outputs.searchResourcePrincipalId
  }
}

module docIntelligenceRoleAssignmentStorage 'modules/rbac/roleAssignment-docIntelligence-storage.bicep' = {
  name: 'modDocIntelligenceRoleAssignmentStorage'
  scope: resourceGroup(resourceGroupNames.storage)
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    managedIdentityPrincipalId: documentIntelligence.outputs.cognitiveServicesPrincipalId
  }
}

module appServiceRoleAssignmentAI 'modules/rbac/roleAssignment-appService-ai.bicep' = {
  name: 'modAppServiceRoleAssignmentAI'
  scope: resourceGroup(resourceGroupNames.ai)
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
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    managedIdentityPrincipalId: webApp.outputs.identityPrincipalId
  }
}

module appServiceRoleAssignmentApps 'modules/rbac/roleAssignment-appService-apps.bicep' = {
  name: 'modAppServiceRoleAssignmentApps'
  scope: resourceGroup(resourceGroupNames.apps)
  params: {
    keyVaultName: keyVault.outputs.name
    managedIdentityPrincipalId: webApp.outputs.identityPrincipalId
  }
}

module functionRoleAssignmentStorage 'modules/rbac/roleAssignment-function-storage.bicep' = {
  name: 'modFunctionRoleAssignmentStorage'
  scope: resourceGroup(resourceGroupNames.storage)
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
    managedIdentityPrincipalId: azureFunction.outputs.functionAppPrincipalId
  }
}

module azureFunctionAppRegistration 'modules/appRegistration/appRegistration.bicep' = if (empty(functionAppEntraIdRegistration.appId)) {
  name: 'modAzureFunctionAppRegistration'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn:[
    resourceGroupApps
  ]
  params: {
    clientAppName: '${prefixNormalized}-custom-skills-functionapp'
  }
}

module aiSearchManagedIdentity 'modules/aiSearch/aiSearch-managedIdentity.bicep' = {
  name: 'modAiSearchManagedIdentity'
  scope: resourceGroup(resourceGroupNames.ai)
  params: {
    searchResourceName: aiSearch.outputs.searchResourceName
  }
}

// Azure Function App for AI Search Custom Skills
module azureFunction 'modules/function/function.bicep' = {
  name: 'modAzureFunction'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn: [
    resourceGroupAI
    docIntelligenceRoleAssignmentStorage
  ]
  params: {
    location: location
    tags: tags
    applicationInsightsName: appInsights.outputs.appInsightsResourceName
    applicationInsightsResourceGroup: resourceGroupNames.monitoring
    appServicePlanName: resourceNames.functionAppServicePlanName
    appKind: functionAppServicePlanConfig.kind
    appServicePlanCapacity: functionAppServicePlanConfig.capacity
    appServicePlanFamily: functionAppServicePlanConfig.family
    appServicePlanSkuName: functionAppServicePlanConfig.skuName
    appServicePlanTier: functionAppServicePlanConfig.tier
    azureFunctionName: resourceNames.functionApp
    azureFunctionStorageName: resourceNames.functionStorageAccountName
    logAnalyticsWorkspaceid: logAnalytics.outputs.logAnalyticsWorkspaceId
    authSettings: {
      clientAppId: empty(functionAppEntraIdRegistration.appId) ? azureFunctionAppRegistration.outputs.appId : functionAppEntraIdRegistration.appId
      authenticationIssuerUri: authenticationIssuerUri
      allowedApplications: [
        aiSearchManagedIdentity.outputs.appId
      ]
    }
    documentIntelligenceServiceInstanceName: documentIntelligence.outputs.cognitiveServicesAccountName
  }
}

module keyVault './modules/keyvault/keyvault.bicep' = {
  name: 'modKeyVault'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn:[
    resourceGroupStorage
  ]
  params: {
    keyVaultName: resourceNames.keyVaultName
    location: location
    tags: tags
  }
}

module serverAppKeyVaultSecret './modules/keyvault/keyvault-secret.bicep' = if (!empty(webAppAuthSettings.serverApp.appSecret)) {
  name: 'modServerAppKeyVaultSecret'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn:[
    keyVault
  ]
  params: {
    keyVaultName: resourceNames.keyVaultName
    secretName: webAppAuthSettings.serverApp.appSecretName!
    secretValue: webAppAuthSettings.serverApp.appSecret!
  }
}

module clientAppKeyVaultSecret './modules/keyvault/keyvault-secret.bicep' = if (!empty(webAppAuthSettings.clientApp.appSecret)) {
  name: 'modClientAppKeyVaultSecret'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn:[
    keyVault
  ]
  params: {
    keyVaultName: resourceNames.keyVaultName
    secretName: webAppAuthSettings.clientApp.appSecretName!
    secretValue: webAppAuthSettings.clientApp.appSecret!
  }
}

// Azure Web App
module webApp 'modules/appService/appService.bicep' = {
  name: 'modWebApp'
  scope: resourceGroup(resourceGroupNames.apps)
  dependsOn: [
    resourceGroupApps
  ]
  params: {
    name: resourceNames.webAppName
    location: location
    tags: tags
    applicationInsightsName: appInsights.outputs.appInsightsResourceName
    applicationInsightsResourceGroup: resourceGroupNames.monitoring
    appKind: webAppServicePlanConfig.kind
    appServicePlanCapacity: webAppServicePlanConfig.capacity
    appServicePlanFamily: webAppServicePlanConfig.family
    appServicePlanSkuName: webAppServicePlanConfig.skuName
    appServicePlanTier: webAppServicePlanConfig.tier
    appServicePlanName: resourceNames.webAppServicePlanName
    runtimeName: 'python'
    runtimeVersion: '3.11'
    appCommandLine: 'python3 -m gunicorn main:app'
    authSettings: {
      enableAuth: webAppAuthSettings.enableAuth
      clientAppId: webAppAuthSettings.clientApp.appId
      serverAppId: webAppAuthSettings.serverApp.appId
      clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
      authenticationIssuerUri: authenticationIssuerUri
      allowedApplications: [
        webAppAuthSettings.clientApp.appId
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
      AZURE_OPENAI_EMB_MODEL_NAME: azureOpenAiConfig.textEmbeddingModel
      AZURE_OPENAI_EMB_DIMENSIONS: 1536
      AZURE_OPENAI_CHATGPT_MODEL: azureOpenAiConfig.chatModel
      AZURE_OPENAI_GPT4V_MODEL: azureOpenAiConfig.visionModel
      AZURE_OPENAI_SERVICE: resourceNames.azureOpenAI
      AZURE_OPENAI_CHATGPT_DEPLOYMENT: first(filter(azureOpenAiConfig.deployments, deployment => deployment.name == azureOpenAiConfig.chatModel)).name
      AZURE_OPENAI_EMB_DEPLOYMENT: first(filter(azureOpenAiConfig.deployments, deployment => deployment.name == azureOpenAiConfig.textEmbeddingModel)).name
      AZURE_OPENAI_GPT4V_DEPLOYMENT: first(filter(azureOpenAiConfig.deployments, deployment => deployment.name == azureOpenAiConfig.visionModel)).name
      USE_VECTORS: true
      USE_GPT4V: true
      PYTHON_ENABLE_GUNICORN_MULTIWORKERS: true
      SCM_DO_BUILD_DURING_DEPLOYMENT: true
      ENABLE_ORYX_BUILD: true
      AZURE_USE_AUTHENTICATION: webAppAuthSettings.enableAuth
      AZURE_SERVER_APP_ID: webAppAuthSettings.serverApp.appId
      AZURE_SERVER_APP_SECRET: '@Microsoft.KeyVault(VaultName=${resourceNames.keyVaultName};SecretName=${webAppAuthSettings.serverApp.appSecretName})'
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=${resourceNames.keyVaultName};SecretName=${webAppAuthSettings.clientApp.appSecretName})'
      AZURE_CLIENT_APP_ID: webAppAuthSettings.clientApp.appId
      AZURE_AUTH_TENANT_ID: tenant().tenantId
      AZURE_ENFORCE_ACCESS_CONTROL: webAppAuthSettings.enableAccessControl
      AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS: true
      AZURE_ENABLE_UNAUTHENTICATED_ACCESS: !webAppAuthSettings.enableAuth
      AZURE_AUTHENTICATION_ISSUER_URI: authenticationIssuerUri
    }
  }
}

// Azure AI Search Configuration
module aiSearchDataSource 'modules/aiSearch/aiSearch-datasource.bicep' = {
  name: 'modAiSearchDataSource'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
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
    deploymentScriptIdentityRoleAssignmentAI
    aiSearchRoleAssignmentAI
    aiSearchRoleAssignmentStorage
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: resourceNames.aiSearchIndexName
    azureOpenAIEndpoint: 'https://${azureOpenAI.outputs.cognitiveServicesAccountName}.openai.azure.com/'
    azureOpenAITextModelName: azureOpenAiConfig.textEmbeddingModel
    cognitiveServicesEndpoint: 'https://${azureAIVision.outputs.cognitiveServicesAccountName}.cognitiveservices.azure.com'
    managedIdentityId: deploymentScriptIdentity.outputs.managedIdentityId
  }
}

// Create AI Search skillset
module aiSearchSkillset 'modules/aiSearch/aiSearch-skillset.bicep' = {
  name: 'modAiSearchSkillset'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearchIndex
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
    azureOpenAITextModelName: azureOpenAiConfig.textEmbeddingModel
    knowledgeStoreStorageResourceUri: 'ResourceId=${storageAccount.outputs.storageAccountId}'
    knowledgeStoreStorageContainer: storageAccountDocsContainerName
    pdfMergeCustomSkillEndpoint: azureFunction.outputs.pdfTextImageMergeSkillEndpoint
    aadAppId: empty(functionAppEntraIdRegistration.appId) ? azureFunctionAppRegistration.outputs.appId : functionAppEntraIdRegistration.appId
    cognitiveServicesAccountId: azureCognitiveServices.outputs.cognitiveServicesAccountId
    managedIdentityId: deploymentScriptIdentity.outputs.managedIdentityId
  }
}

// Create AI Searcher indexer
module aiSearchIndexer 'modules/aiSearch/aiSearch-indexer.bicep' = {
  name: 'modAiSearchIndexer'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
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
