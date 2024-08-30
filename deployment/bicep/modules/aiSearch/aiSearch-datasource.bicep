// This file is used to create a deployment script to create a data source in Azure AI Search service.
@sys.description('Location of the Azure AI Search service.')
param location string

@sys.description('Azure AI Search endpoint.')
param aiSearchEndpoint string

@sys.description('Storage account resource id.')
param storageAccountResourceId string

@sys.description('Container name in the storage account.')
param containerName string

@sys.description('Managed Identity Id to be used for the deployment script')
param managedIdentityId string

// Variable to generate the datasource name
var dataSourceName = '${containerName}-datasource'
var jsonTemplate = loadFileAsBase64('../../../library/datasource_blob_template.json')

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
    arguments: '-aiSearchEndpoint ${aiSearchEndpoint} -storageAccountResourceId ${storageAccountResourceId} -dataSourceName ${dataSourceName} -containerName ${containerName} -jsonTemplate ${jsonTemplate}'
    scriptContent: loadTextContent('../../scripts/aisearch-create-datasource.ps1')
    cleanupPreference: 'OnSuccess'
  }
}
