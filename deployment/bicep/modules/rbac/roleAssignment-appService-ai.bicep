// Parameters
@sys.description('Specifies the Id of the Azure OpenAI resource.')
param azureOpenAIResourceName string

@sys.description('Specifies the Id of the Azure AI Vision resource.')
param azureAIVisionResourceName string

@sys.description('Specifies the Id of the AI Search resource.')
param azureAISearchResourceName string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

// Resources
resource azureAIVisionResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: azureAIVisionResourceName
}

resource azureOpenAIResource 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' existing = {
  name: azureOpenAIResourceName
}

resource azureAISearchResource 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: azureAISearchResourceName
}

// Role Definitions
@description('Reader role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#search-index-data-reader')
resource roleDefinitionAzureAISearchReader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: azureAISearchResource
  name: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

@description('Query an index. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/ai-machine-learning#search-index-data-reader')
resource roleDefinitionAzureAISearchIndexDataReader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: azureAISearchResource
  name: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
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

//Used to read index definitions (required when using authentication)
resource roleAssignmentAzureAISearchReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionAzureAISearchReader.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionAzureAISearchReader.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: azureAISearchResource
}

resource roleAssignmentAzureAISearchIndexDataReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionAzureAISearchIndexDataReader.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionAzureAISearchIndexDataReader.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: azureAISearchResource
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
