@export()
type cognitiveServicesConfig = {
  @description('The location of the resource.')
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
  location: string

  @sys.description('Azure Region where Document Intelligence will be deployed. Support for API 2024-07-31-preview is limited to certain regions.')
  @sys.allowed([
    'eastus'
    'westus2'
    'westeurope'
    'northcentralus'
  ])
  locationOfdocIntelligenceWithApi2024_07_31_preview: string?

  @description('The SKU of the resource.')
  sku: string

  @description('The kind of the cognitive services resource.')
  @sys.allowed(['ComputerVision'])
  kind: 'CognitiveServices' | 'ComputerVision' | 'FormRecognizer' | 'OpenAI'
}

@export()
type azureOpenAiConfig = {
  @description('The cognitive services configuration for the OpenAI resource.')
  cognitiveServicesConfig: cognitiveServicesConfig

  @description('The text embedding model.')
  textEmbeddingModel: string

  @description('The vision model.')
  visionModel: string

  @description('The chat model.')
  chatModel: string

  deployments: azureOpenAiDeployment[]
}

@export()
type webAppAuthSettings = {
  @description('Enable authentication for the web app.')
  enableAuth: bool

  @description('Enable access control for the web app.')
  enableAccessControl: bool

  @description('Server app registration.')
  serverApp: appRegistration

  @description('Client app registration.')
  clientApp: appRegistration
}

@export()
type aiSearchConfig = {
  @description('The location of the resource.')
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
  location: string

  @description('The SKU of the resource.')
  sku: 'basic' | 'free' | 'standard' | 'standard2' | 'standard3' | 'storage_optimized_l1' | 'storage_optimized_l2'

  @description('The capacity of the resource.')
  capacity: int

  @description('The semantic search sku.')
  semanticSearchSku: 'disabled' | 'free' | 'standard'
}

@export()
type appServicePlanConfig = {
  @description('The SKU of the resource.')
  skuName: 'B1' | 'B2' | 'B3' | 'D1' | 'D2' | 'D3' | 'F1' | 'I1' | 'I2' | 'I3' | 'P1' | 'P2' | 'P3' | 'PC2' | 'PC3' | 'PC4' | 'S1' | 'S2' | 'S3' | 'Y1' | 'Y2' | 'Y3'

  @description('The capacity of the resource.')
  capacity: int

  @description('The kind of the resource.')
  kind: string

  @description('The family of the resource.')
  family: string

  @description('The tier of the resource.')
  tier: string
}

@export()
type appRegistration = {
  @description('The app / client id of the app registration.')
  appId: string

  @description('The name of the app secret in the KeyVault.')
  appSecretName: string?

  @description('The secret of the app registration.')
  @secure()
  appSecret: string?
}

@export()
type logAnalyticsConfig = {
  @description('The SKU of the resource.')
  sku: 'CapacityReservation' | 'Free' | 'LACluster' | 'PerGB2018' | 'PerNode' | 'Premium' | 'Standalone' | 'Standard'

  @description('The retention in days.')
  retentionInDays: int
}


type azureOpenAiDeployment = {
  @description('The name of the deployment.')
  name: string

  @description('The model to deploy.')
  model: {
    format: string
    version: string
  }

  @description('The SKU of the deployment.')
  sku: {
    capacity: int
  }
}
