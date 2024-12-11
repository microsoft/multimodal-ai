// Parameters
@sys.description('Specifies the name of the Azure AI Search instance.')
param aiSearchName string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

@sys.description('Specified the name of the Cognitive Service Account resource')
param cognitiveServicesresourceName string

// Resources
resource searchResource 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: aiSearchName
}

resource cognitiveServicesResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: cognitiveServicesresourceName
}

@description('This is the Search Service Contributor built-in role. See https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#ai--machine-learning')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: searchResource
  name: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
}

@description('Enables *READ* permission to the Microsoft.CognitiveServices/acccounts resources via ARM control. plane See https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-user')
resource roleDefinitionCognitiveServiceUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: cognitiveServicesResource
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
}
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinition.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: searchResource
}

resource roleAssignmentCognitiveServiceUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinitionCog', roleDefinitionCognitiveServiceUser.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionCognitiveServiceUser.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: cognitiveServicesResource
}
