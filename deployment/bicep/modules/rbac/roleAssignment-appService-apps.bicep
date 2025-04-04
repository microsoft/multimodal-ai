// Parameters
@sys.description('Specifies the name of the Azure KeyVault instance.')
param keyVaultName string

@sys.description('Managed Identity Principla Id to be assigned access to the search service.')
param managedIdentityPrincipalId string

// Resources
resource keyVaultResource 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Role Definitions
@description('This is the Key Vault Secrets User role. See https://learn.microsoft.com/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations')
resource roleDefinitionKeyVaultSecretsUser 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: keyVaultResource
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

// Role Assignments
resource roleAssignmentKeyVaultSecretsUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('roleDefinition', roleDefinitionKeyVaultSecretsUser.id, managedIdentityPrincipalId)
  properties: {
    roleDefinitionId: roleDefinitionKeyVaultSecretsUser.id
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
  scope: keyVaultResource
}
