using './multimodal-ai.bicep'

param prefix = 'mmai75'

param location = 'eastus2'

param tags = {}

param storageAccountDocsContainerName = 'docs'

param functionAppEntraIdRegistration = {
  appId: ''
}

param aiVisionConfig = {
  location: 'eastus'
  sku: 'S1'
  kind: 'ComputerVision'
}

param docIntelConfig = {
  location: 'eastus'
  locationOfdocIntelligenceWithApi2024_07_31_preview: 'eastus'
  sku: 'S0'
  kind: 'FormRecognizer'
}

param cognitiveServicesConfig = {
  location: aiSearchConfig.location
  sku: 'S0'
  kind: 'CognitiveServices'
}

param aiSearchConfig = {
  location: 'eastus'
  sku: 'standard'
  capacity: 1
  semanticSearchSku: 'standard'
}

param webAppServicePlanConfig = {
  skuName: 'B3'
  capacity: 1
  kind: 'linux'
  family: 'B'
  tier: 'Basic'
}

param functionAppServicePlanConfig = {
  tier: 'Standard'
  skuName: 'S1'
  family: 'S'
  capacity: 1
  kind: 'functionapp,linux'
}

param logAnalyticsConfig = {
  sku: 'PerGB2018'
  retentionInDays: 30
}

param azureOpenAiConfig = {
  cognitiveServicesConfig: {
    kind: 'OpenAI'
    location: 'eastus'
    sku: 'S0'
  }
  textEmbeddingModel: 'text-embedding-ada-002'
  visionModel: 'gpt-4o'
  chatModel: 'gpt-4o'
  deployments: [
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
}

@secure()
param webAppAuthSettings = {
  enableAuth: false
  enableAccessControl: false
  serverApp: {
    appId: ''
    appSecretName: ''
    appSecret: ''
  }
  clientApp: {
    appId: ''
    appSecretName: ''
    appSecret: ''
  }
}
