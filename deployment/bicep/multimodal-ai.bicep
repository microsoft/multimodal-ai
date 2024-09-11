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


@sys.description('Specifies the URI of the MSDeploy Package for the Azure Function.')
param azureFunctionUri string = ''

param aoaiTextEmbeddingModelForAiSearch string

// Variables
var locationNormalized = toLower(location)
var prefixNormalized = toLower(prefix)

var aiSearchIndexName = '${prefixNormalized}index'
var aiSearchSkillsetName = '${prefix}-skillset'

var resourceGroupNames = {
  ai: '${prefixNormalized}-${locationNormalized}-ai-rg'
  storage: '${prefixNormalized}-${locationNormalized}-storage-rg'
  monitoring: '${prefixNormalized}-${locationNormalized}-monitoring-rg'
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
  functionAppUri: azureFunctionUri
  functionStorageAccountName: take('${prefixNormalized}${locationNormalized}functionstg',23)
  logAnalyticsWorkspaceName: '${prefixNormalized}-${locationNormalized}-loganalytics'
  appInsightsName: '${prefixNormalized}-${locationNormalized}-appinsights'
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

// Azure Cognitive Services
module azureCognitiveServices 'modules/cognitiveServices/cognitiveServices.bicep' = {
  name: 'modAzureCognitiveServices'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
  ]
  params: {
    location: location
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
module aiSearchDeploymentScriptIdentity 'modules/managedIdentities/managedIdentity.bicep' = {
  name: 'modAISearchDeploymentScriptIdentity'
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
    location: location
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
module aiSearchRoleAssignment 'modules/rbac/roleAssignment-searchService.bicep' = {
  name: 'modAISearchRoleAssignment'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    aiSearchDeploymentScriptIdentity
  ]
  params: {
    aiSearchId: aiSearch.outputs.searchResourceId
    managedIdentityPrincipalId: aiSearchDeploymentScriptIdentity.outputs.managedIdentityPrincipalId
  }
}

module storageRoleAssignment 'modules/rbac/roleAssignment-blobStorage.bicep' = {
  name: 'modStorageRoleAssignment'
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

module azureOpenAIRoleAssignment 'modules/rbac/roleAssignment-azureOpenAI.bicep' = {
  name: 'modAzureOpenAIRoleAssignment'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    azureOpenAI
  ]
  params: {
    cognitiveServicesAccountId: azureOpenAI.outputs.cognitiveServicesAccountId
    managedIdentityPrincipalId: aiSearch.outputs.searchResourcePrincipalId
  }
}

module azureAIVisionRoleAssignment 'modules/rbac/roleAssignment-cognitiveServices.bicep' = {
  name: 'modAIVisionCognitiveServicesRoleAssignment'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    azureAIVision
  ]
  params: {
    cognitiveServicesAccountId: azureAIVision.outputs.cognitiveServicesAccountId
    managedIdentityPrincipalId: aiSearch.outputs.searchResourcePrincipalId
  }
}

module documentIntelligenceRoleAssignment 'modules/rbac/roleAssignment-cognitiveServices.bicep' = {
  name: 'modDocIntelCognitiveServicesRoleAssignment'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    documentIntelligence
  ]
  params: {
    cognitiveServicesAccountId: documentIntelligence.outputs.cognitiveServicesAccountId
    managedIdentityPrincipalId: aiSearch.outputs.searchResourcePrincipalId
  }
}

// Azure Function for AI Search Custom Skills
module azureFunction 'modules/function/function.bicep' = {
  name: 'modAzureFunction'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    resourceGroupAI
    storageAccount
  ]
  params: {
    location: location
    appServiceCapacity: appServicePlan.capacity
    appServiceFamily: appServicePlan.family
    appServiceName: appServicePlan.name
    appServiceSize: appServicePlan.size
    appServiceTier: appServicePlan.tier
    azureFunctionName: resourceNames.functionApp
    azureFunctionZipUri: resourceNames.functionAppUri
    azureFunctionStorageName: resourceNames.functionStorageAccountName
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
    storageRoleAssignment
    aiSearchRoleAssignment
  ]
  params: {
    location: location
    dataSourceName: resourceNames.aiSearchDocsDataSourceName
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    storageAccountResourceId: storageAccount.outputs.storageAccountId
    containerName: storageAccountDocsContainerName
    managedIdentityId: aiSearchDeploymentScriptIdentity.outputs.managedIdentityId
  }
}

// Create AI Search index
module aiSearchIndex 'modules/aiSearch/aiSearch-index.bicep' = {
  name: 'modAiSearchIndex'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    azureAIVisionRoleAssignment
    azureOpenAIRoleAssignment
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: aiSearchIndexName
    azureOpenAIEndpoint: 'https://${azureOpenAI.outputs.cognitiveServicesAccountName}.openai.azure.com/'
    azureOpenAITextModelName: aoaiTextEmbeddingModelForAiSearch
    cognitiveServicesEndpoint: 'https://${azureAIVision.outputs.cognitiveServicesAccountName}.cognitiveservices.azure.com'
    managedIdentityId: aiSearchDeploymentScriptIdentity.outputs.managedIdentityId
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
    storageRoleAssignment
    aiSearchRoleAssignment
    azureAIVisionRoleAssignment
    azureOpenAIRoleAssignment
    azureCognitiveServices
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: aiSearchIndexName
    skillsetName: aiSearchSkillsetName
    azureOpenAIEndpoint: 'https://${azureOpenAI.name}.openai.azure.com/'
    azureOpenAITextModelName: aoaiTextEmbeddingModelForAiSearch
    knowledgeStoreStorageResourceUri: 'ResourceId=${storageAccount.outputs.storageAccountId}'
    knowledgeStoreStorageContainer: storageAccountDocsContainerName
    pdfMergeCustomSkillEndpoint: azureFunction.outputs.pdfTextImageMergeSkillEndpoint
    cognitiveServicesAccountId: azureCognitiveServices.outputs.cognitiveServicesAccountId
    managedIdentityId: aiSearchDeploymentScriptIdentity.outputs.managedIdentityId
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
    storageRoleAssignment
    aiSearchRoleAssignment
    azureAIVisionRoleAssignment
    azureOpenAIRoleAssignment
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: aiSearchIndexName
    skillsetName : aiSearchSkillsetName
    dataSourceName: resourceNames.aiSearchDocsDataSourceName
    managedIdentityId: aiSearchDeploymentScriptIdentity.outputs.managedIdentityId
  }
}
