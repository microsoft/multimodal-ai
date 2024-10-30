targetScope = 'resourceGroup'

@sys.description('Azure Region where the App Service and Function will be created.')
param location string

@sys.description('Name of the App Service to be created.')
param appServicePlanName string

@sys.description('Tier of the App Service  to be created.')
param appServicePlanTier string

@sys.description('Size of the App Service  to be created.')
param appServicePlanSkuName string

@sys.description('Family of the App Service  to be created.')
param appServicePlanFamily string

@sys.description('Capacity of the App Service  to be created.')
param appServicePlanCapacity int

@sys.description('Kind of the app.')
param appKind string

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

@sys.description('Name of the document intelligence service instance to be used.')
param documentIntelligenceServiceInstanceName string

@sys.description('Tags you would like to be applied to the resource.')
param tags object = {}

@sys.description('Settings to configure function app authentication.')
param authSettings object = {
  clientAppId: ''
  authenticationIssuerUri: ''
  allowedApplications: []
}

// Reference to existing Application Insights resource
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
  scope: resourceGroup(applicationInsightsResourceGroup)
}

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

// create hosting plan
resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  kind: appKind
  tags: tags
  sku: {
    tier: appServicePlanTier
    name: appServicePlanSkuName
    size: appServicePlanSkuName
    family: appServicePlanFamily
    capacity: appServicePlanCapacity
  }
  properties: {
    reserved: true
  }
}

// create function app
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: azureFunctionName
  location: location
  tags: tags
  kind: appKind

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      alwaysOn: true
      linuxFxVersion: 'Python|3.11'
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
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
        {
          name: 'DOCUMENT_INTELLIGENCE_SERVICE'
          value: documentIntelligenceServiceInstanceName
        }
      ]
    }
  }

  resource configAuth 'config' = {
    name: 'authsettingsV2'
    properties: {
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'Return401'
        redirectToProvider: 'azureactivedirectory'
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          registration: {
            clientId: authSettings.clientAppId
            openIdIssuer: authSettings.authenticationIssuerUri
          }
          validation: {
            defaultAuthorizationPolicy: {
              allowedApplications: authSettings.allowedApplications
            }
          }
        }
      }
    }
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

output functionAppId string = functionApp.id
output functionAppName string = functionApp.name
output functionAppPrincipalId string = functionApp.identity.principalId
output pdfTextImageMergeSkillEndpoint string = 'https://${functionApp.properties.defaultHostName}/api/pdf_text_image_merge_skill'
