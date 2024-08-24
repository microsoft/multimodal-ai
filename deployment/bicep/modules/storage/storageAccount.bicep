@sys.description('Name of the Storage Account to be created.')
param storageAccountName string

@sys.description('Azure Region where the Storage Account will be created.')
param location string

@sys.description('Storage account Kind.')
@sys.allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param kind string = 'StorageV2'

@sys.description('Storage account SKU.')
@sys.allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'  
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'  
])
param sku string = 'Standard_LRS'

@sys.description('Name of the container to be created.')
param containerName string

@sys.description('Tags you would like to be applied to the resource group.')
param tags object = {}

// Variables
var storageAccountNameCleaned = take(replace(storageAccountName, '-', ''), 23)

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountNameCleaned
  location: location
  tags: tags

  kind: kind
  sku: {
    name: sku
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
  }
}

// Blob Services
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  name: 'default'
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

// Container
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: containerName
  parent: blobServices
  properties: {
    publicAccess: 'None'
  }
}

output storageAccountId string = storageAccount.id
