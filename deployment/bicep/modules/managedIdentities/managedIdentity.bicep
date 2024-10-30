targetScope = 'resourceGroup'

metadata name = 'User Assigned Managed Identity'
metadata description = 'Module for deploying a User Assigned Managed Identity.'

// Parameters
@sys.description('Specifies the name of the Managed Identity.')
param name string

@sys.description('The region to deploy the deployment resources into.')
param location string

//Resources
@description('The user assigned managed identity to create.')
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: location
}

output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
