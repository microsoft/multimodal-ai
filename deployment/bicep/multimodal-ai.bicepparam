using './multimodal-ai.bicep'

param prefix = 'mmai'
param location = 'eastus'

param aiVisionlocation = 'eastus'
param aiVisionKind = 'ComputerVision'
param aiVisionSku = 'S1'

param docIntelLocation = 'eastus'
param docIntelKind = 'FormRecognizer'
param docIntelSku = 'S0'

param aiSearchSku = 'standard'
param aiSearchCapacity = 1
param aiSearchSemanticSearch = 'standard'

param cogsvcSku = 'S0'
param cogsvcKind = 'CognitiveServices'

param storageAccountDocsContainerName = 'docs'

// Replace with real app
param azureFunctionUri = ''

param aoaiKind = 'OpenAI'
param aoaiSku = 'S0'
param aoaiTextEmbeddingModelForAiSearch = 'text-embedding-ada-002'
param tags = {}

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
