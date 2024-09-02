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

@sys.description('Specifies the container name to be created in the storage account for images.')
param storageAccountImagesContainerName string

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
}

var appServicePlan = {
  tier: 'Standard'
  name: resourceNames.appServicePlan
  size: 'S1'
  family: 'S'
  capacity: 1
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

module aiSearchRoleDef 'modules/rbac/roleDef-searchServiceContributor.bicep' = {
  name: 'modAISearchRoleDef'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
    aiSearchDeploymentScriptIdentity
  ]
  params: {
    aiSearchId: aiSearch.outputs.searchResourceId
  }
}

module aiSearchRoleAssignment 'modules/rbac/roleAssignment.bicep' = {
  name: 'modAISearchRoleAssignment'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearchRoleDef
  ]
  params: {
    managedIdentityPrincipalId: aiSearchDeploymentScriptIdentity.outputs.managedIdentityPrincipalId
    roleDefinitionId: aiSearchRoleDef.outputs.roleDefinitionId
  }
}

// Role Assignments
module storageRoleDef 'modules/rbac/roleDef-blobDataReader.bicep' = {
  name: 'modStorageRoleDef'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn: [
    storageAccount
    aiSearch
  ]
  params: {
    storageAccountId: storageAccount.outputs.storageAccountId
  }
}

module storageRoleAssignment 'modules/rbac/roleAssignment.bicep' = {
  name: 'modStorageRoleAssignment'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn: [
    storageRoleDef
  ]
  params: {
    managedIdentityPrincipalId: aiSearch.outputs.searchResourcePrincipalId
    roleDefinitionId: storageRoleDef.outputs.roleDefinitionId
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

// Create AI Search index
module aiSearchIndex 'modules/aiSearch/aiSearch-index.bicep' = {
  name: 'modAiSearchIndex'
  scope: resourceGroup(resourceGroupNames.ai)
  dependsOn: [
    aiSearch
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
    knowledgeStoreStorageContainer: storageAccountImagesContainerName
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
  ]
  params: {
    location: location
    aiSearchEndpoint: last(split(aiSearch.outputs.searchResourceId, '/'))
    indexName: aiSearchIndexName
    skillsetName : aiSearchSkillsetName
    dataSourceName: aiSearchDataSource.outputs.dataSourceName
    managedIdentityId: aiSearchDeploymentScriptIdentity.outputs.managedIdentityId
  }
}
