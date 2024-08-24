@sys.description('Name of the blob Services to be created.')
param blobServicesName string = 'blobSvcs'

@sys.description('Specifies the Id of the Storage Account.')
param storageAccountId string

// Variables
var storageAccountName = last(split(storageAccountId, '/'))

// Resources

// Existing Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// Blob Services
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  name: blobServicesName
  parent: storageAccount
  properties: {
    
    defaultServiceVersion: '2020-10-02'
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    isVersioningEnabled: true
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Outputs
output blobServicesId string = blobServices.id
