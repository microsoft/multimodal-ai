targetScope = 'subscription'

// Parameters
@sys.description('Prefix for the resources to be created')
@maxLength(8)
param prefix string = ''

@sys.description('Azure Region where the resources will be created.')
param location string = ''

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
  'eastasia'
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
var aiVisionSku = 'F0'

// Azure OpenAI
var aoaiKind = 'OpenAI'
var aoaiSku = 'S0'

// Document Intelligence
var docIntelKind = 'FormRecognizer'
var docIntelSku = 'S0'

var resourceGroupNames = {
  ai: '${prefixNormalized}-${locationNormalized}-ai'
}

var resourceNames = {
  aiVision: '${prefixNormalized}-${locationNormalized}-ai-vision'
  azureOpenAI: '${prefixNormalized}-${locationNormalized}-aoai'
  documentIntelligence: '${prefixNormalized}-${locationNormalized}-docintel'
}

// Resources
module resourceGroupAI './modules/resourceGroup/resourceGroup.bicep' = {
  name: 'modResourceGroupAI'
  params: {
    location: location
    resourceGroupName: resourceGroupNames.ai
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
