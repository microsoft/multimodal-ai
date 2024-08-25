@sys.description('Name of the Azure OpenAI deployment to be created.')
param name string

@sys.description('Version of the Azure OpenAI deployment to be created.')
param version string

@sys.description('Format of the Azure OpenAI deployment to be created.')
param format string = 'OpenAI'

@sys.description('Capacity of the Azure OpenAI deployment.')
param capacity int

@sys.description('Sku name of the Azure OpenAI deployment.')
@allowed([
  'Manual'
  'Standard'
])
param skuName string = 'Standard'

@sys.description('Specifies the Id of the Cognitive Services account.')
param cognitiveServicesAccountId string

// Variables
var cognitiveServicesAccountName = last(split(cognitiveServicesAccountId, '/'))

// Resources
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: cognitiveServicesAccountName
}

resource aoaiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  name: name
  parent: cognitiveServicesAccount
  
  sku: {
    capacity: capacity
    name: skuName
  }
  properties: {
    model: {
      format: format
      name: name
      version: version
    }        
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
  }
}
