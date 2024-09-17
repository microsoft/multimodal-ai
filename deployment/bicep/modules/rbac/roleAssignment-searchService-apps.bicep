// Parameters
@sys.description('Specifies the Id of the Storage Account instance.')
param functionAppId string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

// Variables
var functionAppName = last(split(functionAppId, '/'))

// Resources
resource functionAppResource 'Microsoft.Web/sites@2023-12-01' existing = {
  name: functionAppName
}

// Role Definitions
@description('Contributor role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/general#contributor')
resource roleDefinitionContributor'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: functionAppResource
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

// Role Assignments
resource roleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionContributor.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionContributor.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: functionAppResource
}
