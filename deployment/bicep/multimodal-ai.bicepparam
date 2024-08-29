using './multimodal-ai.bicep'

param prefix = 'mmai16'
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

param aoaiKind = 'OpenAI'
param aoaiSku = 'S0'
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

param tags = {}
