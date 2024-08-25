targetScope = 'subscription'

// Parameters
@sys.description('Prefix for the resources to be created')
@maxLength(8)
param prefix string = ''

@sys.description('Azure Region where the resources will be created.')
param location string = ''

@sys.description('Azure OpenAI deployments to be created.')
param aoaiDeployments array = []

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

@sys.description('Azure Region where Document Intelligence will be deployed. Support for API 2024-07-31-preview is limited to certain regions.')
@sys.allowed([
  'eastus'  
  'westus2'  
  'westeurope'
  'northcentralus'  
])
param docIntelLocation string

@sys.description('Specifies the tags which will be applied to all resources.')
param tags object = {}

// Variables
var locationNormalized = toLower(location)
var prefixNormalized = toLower(prefix)

// AI Vision
var aiVisionKind = 'ComputerVision'
var aiVisionSku = 'S1'

// Azure OpenAI
var aoaiKind = 'OpenAI'
var aoaiSku = 'S0'

// Document Intelligence
var docIntelKind = 'FormRecognizer'
var docIntelSku = 'S0'

// AI Search
var aiSearchSku = 'standard'
var aiSearchCapacity = 1
var aiSearchSemanticSearch = 'disabled'

// Cognitive Services
var cogsvcSku = 'S0'
var cogsvcKind = 'CognitiveServices'

// Storage Account
var docsContainerName = 'docs'

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

module storageAccount 'modules/storage/storageAccount.bicep' = {
  name: 'modStorageAccount'
  scope: resourceGroup(resourceGroupNames.storage)
  dependsOn: [
    resourceGroupStorage
  ]
  params: {
    storageAccountName: resourceNames.storageAccount
    containerName: docsContainerName
    location: location    
    tags: tags
  }
}
