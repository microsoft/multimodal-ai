// Parameters
@sys.description('Specifies the Id of the Azure OpenAI resource.')
param azureOpenAIResourceId string

@sys.description('Specifies the Id of the Azure AI Vision resource.')
param azureAIVisionResourceId string

@sys.description('Specifies the Id of the Azure AI Vision resource.')
param documentIntelligenceResourceId string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

// Variables
var azureOpenAIResourceName = last(split(azureOpenAIResourceId, '/'))
var azureAIVisionResourceName = last(split(azureAIVisionResourceId, '/'))
var documentIntelligenceResourceName = last(split(documentIntelligenceResourceId, '/'))

// Resources
resource documentIntelligenceResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: documentIntelligenceResourceName
}

resource azureAIVisionResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: azureAIVisionResourceName
}

resource azureOpenAIResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: azureOpenAIResourceName
}

// Role Definitions
@description('Lets you read and list keys of Cognitive Services. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-user')
resource roleDefinitionDocumentIntelligenceCognitiveServicesUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: documentIntelligenceResource
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
}

@description('Lets you read and list keys of Cognitive Services. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-user')
resource roleDefinitionAzureAIVisionCognitiveServicesUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: azureAIVisionResource
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
}

@description('Read access to view files, models, deployments. The ability to create completion and embedding calls. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#cognitive-services-openai-user')
resource roleDefinitionOpenAIUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: azureOpenAIResource
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
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

resource roleAssignmentAzureAIVisionCognitiveServicesUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionAzureAIVisionCognitiveServicesUser.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionAzureAIVisionCognitiveServicesUser.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: azureAIVisionResource
}

resource roleAssignmentAzureOpenAIUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionOpenAIUser.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionOpenAIUser.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: azureOpenAIResource
}
