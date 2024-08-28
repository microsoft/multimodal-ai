// Parameters
@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

@sys.description('Role Definition Id to be assigned to the managed identity.')
param roleDefinitionId string

// Resources
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionId)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}
