// This file is used to create a deployment script to create an indexer in Azure AI Search service.
@sys.description('Location of the Azure AI Search service.')
param location string

@sys.description('Azure AI Search endpoint.')
param aiSearchEndpoint string

@sys.description('Name of the Azure AI Search index.')
param indexName string

@sys.description('Name of the Azure AI Search skillset that indexer will use.')
param skillsetName string

@sys.description('Name of datasource.')
param dataSourceName string

@sys.description('Managed Identity Id to be used for the deployment script')
param managedIdentityId string

var indexerName = '${indexName}-indexer'
var jsonTemplate = loadFileAsBase64('../../../library/indexer_template.json')

resource aiSearchIndexer 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'aiSearchIndexer'
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
    arguments: '-dataSourceName ${dataSourceName} -aiSearchEndpoint ${aiSearchEndpoint} -indexName ${indexName} -indexerName ${indexerName} -skillsetName ${skillsetName} -jsonTemplate ${jsonTemplate}'
    scriptContent: loadTextContent('../../scripts/aisearch-create-indexer.ps1')
    cleanupPreference: 'OnSuccess'
  }
}
