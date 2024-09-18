// Parameters
@sys.description('Specifies the Id of the Azure AI Vision resource.')
param documentIntelligenceResourceId string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

// Variables
var documentIntelligenceResourceName = last(split(documentIntelligenceResourceId, '/'))

// Resources
resource documentIntelligenceResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: documentIntelligenceResourceName
}

// Role Definitions
@description('Lets you read and list keys of Cognitive Services. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-user')
resource roleDefinitionDocumentIntelligenceCognitiveServicesUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: documentIntelligenceResource
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
}

// Role Assignments
resource roleAssignmentDocumentIntelligenceCognitiveServicesUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionDocumentIntelligenceCognitiveServicesUser.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionDocumentIntelligenceCognitiveServicesUser.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: documentIntelligenceResource
}
