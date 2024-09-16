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

@sys.description('Log Analytics Workspace Id for the Azure Function.')
param logAnalyticsWorkspaceid string

@sys.description('Name of the Application Insights resource.')
param applicationInsightsName string

@sys.description('Name of the Application Insights resource group.')
param applicationInsightsResourceGroup string

@sys.description('Tags you would like to be applied to the resource.')
param tags object = {}

//creating a storage account for the Azure Function
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: azureFunctionStorageName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

// Reference to existing Application Insights resource
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
  scope: resourceGroup(applicationInsightsResourceGroup)
}

// create hosting plan
resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServiceName
  location: location
  tags: tags
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
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: azureFunctionName
  location: location
  tags: tags
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
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
  }
}

// Grant Blob Data Contributor assignment to the Function managed identity
module functionRoleAssignmentStorage '../rbac/roleAssignment-function-storage.bicep' = {
  name: 'functionRoleAssignmentStorage'
  params: {
    storageAccountId: storageAccount.id
    managedIdentityPrincipalId: functionApp.identity.principalId
  }
}

// enabling Log Analytics on the Azure Function
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'functionAppDiagnostics'
  scope: functionApp
  properties: {
    workspaceId: logAnalyticsWorkspaceid
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

//
// zip up the Function source code
/* var functionAppPath = '../../../../backend/skills/pdf_text_image_merge_skill'
resource zipFile 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'FunctionZipFile'
  kind: 'AzurePowerShell'
  location: location
  properties: {
    azPowerShellVersion: '8.3'
    retentionInterval: 'PT1H'
    timeout: 'PT1H'
    arguments: '-arg1 ${functionAppPath} -arg2 ${azureFunctionName}.zip'
    scriptContent: '''
      $functionAppPath = "$arg1"
      $zipFile = "$arg2"
      Compress-Archive -Path $functionAppPath -DestinationPath $zipFile
      $zipFile
    '''
  }
}

// deploy the zip file to the Function App
resource deployApptoFunction 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'deployApptoFunction'
  kind: 'AzureCLI'
  location: location
  properties: {
    azCliVersion: '2.0.80'
    retentionInterval: 'PT1H'
    timeout: 'PT1H'
    arguments: '-arg1 ${azureResourceGroup} -arg2 ${azureFunctionName} -arg3 ${azureFunctionName}.zip'
    scriptContent: '''
      az functionapp deployment source config-zip -g $1 -n $2 --src $3 --build-remote true
    '''
  }
} */

/*
Blocker issue: The deploymentScripts resource is not supported in the current environment.
*/

output pdfTextImageMergeSkillEndpoint string = 'https://${functionApp.properties.defaultHostName}/api/pdf_text_image_merge_skill'
