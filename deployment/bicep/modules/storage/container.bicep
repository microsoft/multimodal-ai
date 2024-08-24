@sys.description('Name of the container to be created.')
param containerName string

@sys.description('Specifies the Id of the blob Services.')
param blobServicesId string

// Variables
// Variables
var blobServicesName = last(split(blobServicesId, '/'))

// Resources

// Blob Services Id
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' existing = {
  name: blobServicesName
}

// Container
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: containerName
  parent: blobServices
  properties: {
    publicAccess: 'None'
  }
}

// Outputs
output containerId string = container.id
