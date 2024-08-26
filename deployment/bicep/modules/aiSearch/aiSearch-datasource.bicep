// This file is used to create a deployment script to create a data source in Azure AI Search service.
@sys.description('Location of the Azure AI Search service.')
param location string

@sys.description('For for the data source configuration in AI Search.')
param dataSourceName string

@sys.description('Supported data source type.')
@sys.allowed(['azureblob', 'azuretable', 'azuresql', 'cosmosdb'])
param dataSourceType string = 'azureblob'

@sys.description('Azure AI Search endpoint.')
param aiSearchEndpoint string

@sys.description('Storage account resource id.')
param storageAccountResourceId string

@sys.description('Container name in the storage account.')
param containerName string

@sys.description('Managed Identity Id to be used for the deployment script')
param managedIdentityId string

resource aiSearchDataSource 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'aiSearchDataSource'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    retentionInterval: 'PT1H'
    timeout: 'PT1H'
    arguments: '-aiSearchEndpoint ${aiSearchEndpoint} -storageAccountResourceId ${storageAccountResourceId} -dataSourceName ${dataSourceName} -dataSourceType ${dataSourceType} -containerName ${containerName}'
    scriptContent: loadTextContent('../../scripts/aisearch-create-datasource.ps1')
    cleanupPreference: 'OnSuccess'
  }
}
