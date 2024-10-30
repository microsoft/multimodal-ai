targetScope = 'resourceGroup'

@sys.description('Azure Region where the Cognitive Services Account will be created.')
param location string

@sys.description('Name of the Cognitive Services account to be created.')
param name string

@sys.description('SKU of the Cognitive Services account to be created.')
param sku string

@sys.description('Kind of the Cognitive Services account to be created.')
@sys.allowed([
  'OpenAI'
  'ComputerVision'
  'FormRecognizer'
  'CognitiveServices'
])
param kind string

@sys.description('Tags you would like to be applied to the resource group.')
param tags object = {}

resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: name
  location: location
  tags: tags

  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: sku
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

output cognitiveServicesAccountId string = cognitiveServicesAccount.id
output cognitiveServicesAccountName string = cognitiveServicesAccount.name
output cognitiveServicesPrincipalId string = cognitiveServicesAccount.identity.principalId
