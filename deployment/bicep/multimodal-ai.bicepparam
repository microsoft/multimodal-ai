using './multimodal-ai.bicep'

param prefix = 'mmai80'
param location = 'eastus2'

param aiVisionlocation = 'eastus'
param aiVisionKind = 'ComputerVision'
param aiVisionSku = 'S1'

param docIntelLocation = 'eastus'
param docIntelKind = 'FormRecognizer'
param docIntelSku = 'S0'

param aiSearchLocation = 'eastus'
param aiSearchSku = 'standard'
param aiSearchCapacity = 1
param aiSearchSemanticSearch = 'standard'

param cogsvcSku = 'S0'
param cogsvcKind = 'CognitiveServices'

param storageAccountDocsContainerName = 'docs'

param aoaiKind = 'OpenAI'
param aoaiSku = 'S0'
param aoaiTextEmbeddingModel = 'text-embedding-ada-002'
param aoaiChatModel = 'gpt-4o'
param aoaiVisionModel = 'gpt-4o'
param tags = {}

param appServiceSkuName = 'B3'

param functionAppClientId = ''

param aoaiDeployments = [
  {
    name: 'text-embedding-ada-002'
    model: {
      format: 'OpenAI'
      version: '2'
    }
    sku: {
      capacity: 30
    }
  }
  {
    name: 'gpt-4o'
    model: {
      format: 'OpenAI'
      version: '2024-05-13'
    }
    sku: {
      capacity: 20
    }
  }
  {
    name: 'gpt-35-turbo'
    model: {
      format: 'OpenAI'
      version: '0613'
    }
    sku: {
      capacity: 60
    }
  }
]

@secure()
param authSettings = {
  isAuthEnabled: false
  enforceAccessControl: false
  serverApp: {
    appId: ''
    appSecret: ''
  }
  clientApp: {
    appId: ''
  }
}
