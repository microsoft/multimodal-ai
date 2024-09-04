@sys.description('Specifies the Id of the cognitive services account.')
param cognitiveServicesAccountId string

// Variables
var cognitiveServicesAccountName = last(split(cognitiveServicesAccountId, '/'))

// Resources
resource cognitiveServicesResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: cognitiveServicesAccountName
}

@description('Read access to view files, models, deployments. The ability to create completion and embedding calls. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: cognitiveServicesResource
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
}

output roleDefinitionId string = roleDefinition.id
