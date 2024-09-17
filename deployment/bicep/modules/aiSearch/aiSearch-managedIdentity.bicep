@sys.description('Name of the AI Search resource.')
param searchResourceName string

resource searchResource 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: searchResourceName
}

resource aiSearchManagedIdentity 'Microsoft.ManagedIdentity/identities@2018-11-30' existing = {
  scope: searchResource
  name: 'default'
}

output appId string = aiSearchManagedIdentity.properties.clientId
