// This file is used to create a deployment script to create an Azure AI Search skillset.
@sys.description('Location of the Azure AI Search service.')
param location string

@sys.description('Azure AI Search endpoint.')
param aiSearchEndpoint string

@sys.description('Name of the Azure AI Search index.')
param indexName string

@sys.description('Name of the Azure AI Search skillset.')
param skillsetName string

@sys.description('Azure OpenAI endpoint to use.')
param azureOpenAIEndpoint string

@sys.description('Azure OpenAI model to use.')
param azureOpenAITextModelName string

@sys.description('Endpoint for the pdf merge custom skill')
param pdfMergeCustomSkillEndpoint string

@sys.description('ResourceUri of the storage account used for the knowledgestore')
param knowledgeStoreStorageResourceUri string

@sys.description('Name of the storage container used to store pdf page images')
param knowledgeStoreStorageContainer string

@sys.description('Endpoint for the multi service account')
param aiMultiServiceAccountEndpoint string

@sys.description('Managed Identity Id to be used for the deployment script')
param managedIdentityId string

@sys.description('App id of the Microsoft Entra ID app to be used for api auth.')
param aadAppId string

var jsonTemplate = loadFileAsBase64('../../../library/skillset_template.json')

resource aiSearchSkillset 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'aiSearchSkillset'
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
    arguments: '-aiSearchEndpoint ${aiSearchEndpoint} -indexName ${indexName} -skillsetName ${skillsetName} -azureOpenAIEndpoint ${azureOpenAIEndpoint} -azureOpenAITextDeploymentId ${azureOpenAITextModelName} -azureOpenAITextModelName ${azureOpenAITextModelName} -aiMultiServiceAccountEndpoint ${aiMultiServiceAccountEndpoint} -pdfMergeCustomSkillEndpoint ${pdfMergeCustomSkillEndpoint} -knowledgeStoreStorageResourceUri ${knowledgeStoreStorageResourceUri} -knowledgeStoreStorageContainer ${knowledgeStoreStorageContainer} -aadAppId ${aadAppId} -jsonTemplate ${jsonTemplate}'
    scriptContent: loadTextContent('../../scripts/aisearch-create-skillset.ps1')
    cleanupPreference: 'OnSuccess'
  }
}
