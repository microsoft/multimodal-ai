// This file is used to create a deployment script to create an index in Azure AI Search service.
@sys.description('Location of the Azure AI Search service.')
param location string

@sys.description('Azure AI Search endpoint.')
param aiSearchEndpoint string

@sys.description('Name of the Azure AI Search index.')
param indexName string

@sys.description('Azure OpenAI endpoint to use.')
param azureOpenAIEndpoint string

@sys.description('Azure OpenAI model to use.')
param azureOpenAITextModelName string

@sys.description('Cognitive services account to use for AI Vision')
param cognitiveServicesEndpoint string

@sys.description('Managed Identity Id to be used for the deployment script')
param managedIdentityId string

var jsonTemplate = loadFileAsBase64('../../../library/index_template.json')

resource aiSearchIndex 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'aiSearchIndex'
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
    arguments: '-aiSearchEndpoint ${aiSearchEndpoint} -indexName ${indexName} -azureOpenAIEndpoint ${azureOpenAIEndpoint} -azureOpenAITextDeploymentId ${azureOpenAITextModelName} -azureOpenAITextModelName ${azureOpenAITextModelName} -cognitiveServicesEndpoint ${cognitiveServicesEndpoint} -jsonTemplate ${jsonTemplate}'
    scriptContent: loadTextContent('../../scripts/aisearch-create-index.ps1')
    cleanupPreference: 'OnSuccess'
  }
}

