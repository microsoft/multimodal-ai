// File-New-Tenant Parameters
@sys.description('Specifies the Id of the Storage Account instance.')
param storageAccountId string

// Variables
var storageAccountName = last(split(storageAccountId, '/'))

// Resources
resource storageResource 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

@description('This is the Storage Blob Data Reader role. See https://learn.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#storage')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: storageResource
  name: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

output roleDefinitionId string = roleDefinition.id
