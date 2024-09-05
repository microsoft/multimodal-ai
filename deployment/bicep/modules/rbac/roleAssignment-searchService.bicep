// Parameters
@sys.description('Specifies the Id of the Azure AI Search instance.')
param aiSearchId string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

// Variables
var aiSearchName = last(split(aiSearchId, '/'))

// Resources
resource searchResource 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: aiSearchName
}

@description('This is the Search Service Contributor built-in role. See https://learn.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#ai--machine-learning')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: searchResource
  name: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinition.id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: searchResource
}
