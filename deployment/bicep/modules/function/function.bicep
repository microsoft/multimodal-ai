targetScope = 'resourceGroup'

@sys.description('Azure Region where the App Service and Function will be created.')
param location string

// App Service Plan
@sys.description('Tier of the App Service  to be created.')
param appServiceTier string

@sys.description('Name of the App Service to be created.')
param appServiceName string

@sys.description('Size of the App Service  to be created.')
param appServiceSize string

@sys.description('Family of the App Service  to be created.')
param appServiceFamily string

@sys.description('Capacity of the App Service  to be created.')
param appServiceCapacity int

//Azure Function
@sys.description('Name of the Azure Function to be created.')
param azureFunctionName string

@sys.description('Name of the Azure Function Storage Account to be created.')
param azureFunctionStorageName string

@sys.description('Zip file URI for the Azure Function to be created.')
param azureFunctionZipUri string

// creating a storage account for the Azure Function
// resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
//   name: azureFunctionStorageName
//   location: location
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'
//   properties: {
//     supportsHttpsTrafficOnly: true
//   }
// }

// create hosting plan
resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServiceName
  location: location
  sku: {
    tier: appServiceTier
    name: appServiceSize
    size: appServiceSize
    family: appServiceFamily
    capacity: appServiceCapacity
  }
  properties: {}
}

// create function app
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: azureFunctionName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      alwaysOn: true
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
//        {
//          name: 'AzureWebJobsStorage'
//          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=core.windows.net'
//        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: azureFunctionZipUri
        }
      ]
    }
  }
}

// grant Blob Data Contributor assignment to the managed identity
// perhaps should be moved to modules/rbac/*
// resource storageResource 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
//   name: azureFunctionStorageName
// }

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, functionApp.id, 'StorageBlobDataContributor')
//   scope: storageResource
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
//     principalId: functionApp.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }
