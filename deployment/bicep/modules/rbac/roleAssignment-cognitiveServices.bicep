// Parameters
@sys.description('Specifies the Id of the cognitive services account.')
param cognitiveServicesAccountId string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

// Variables
var cognitiveServicesAccountName = last(split(cognitiveServicesAccountId, '/'))

// Resources
resource cognitiveServicesResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: cognitiveServicesAccountName
}

@description('Lets you read and list keys of Cognitive Services. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-user')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: cognitiveServicesResource
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinition.id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: cognitiveServicesResource
}
