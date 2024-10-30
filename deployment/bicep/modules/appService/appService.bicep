@sys.description('Name of the App Service Resource.')
param name string

@sys.description('Name of the App Service Plan Resource.')
param appServicePlanName string

@sys.description('Location of the App Service.')
param location string

@sys.description('Tags you would like to be applied to the resource.')
param tags object = {}

@sys.description('Tier of the App Service to be created.')
param appServicePlanTier string

@sys.description('Size of the App Service to be created.')
param appServicePlanSkuName string

@sys.description('Family of the App Service to be created.')
param appServicePlanFamily string

@sys.description('Capacity of the App Service to be created.')
param appServicePlanCapacity int

@sys.description('Kind of the app.')
param appKind string

@sys.description('Name of the Application Insights resource.')
param applicationInsightsName string

@sys.description('Name of the Application Insights resource group.')
param applicationInsightsResourceGroup string

// Runtime Properties
@sys.description('Runtime to be used.')
@allowed([
  'dotnet', 'dotnetcore', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'
])
param runtimeName string

@sys.description('Specific runtime verion to be used.')
param runtimeVersion string

@sys.description('App command line to launch.')
param appCommandLine string

@sys.description('App settings to be used by the application.')
@secure()
param appSettings object = {}

@sys.description('Settings to configure web app authentication.')
param authSettings object = {
  enableAuth: false
  clientAppId: ''
  serverAppId : ''
  clientSecretSettingName: ''
  authenticationIssuerUri: ''
  allowedApplications: []
}

var use32BitWorkerProcess = appServicePlanSkuName == 'F1'
var alwaysOn = appServicePlanSkuName != 'F1'
var reserved = contains(toLower(appKind), 'linux')
var runtimeNameAndVersion = '${runtimeName}|${runtimeVersion}'
var linuxFxVersion = contains(appKind, 'linux') ? runtimeNameAndVersion : null
var ftpsState = 'FtpsOnly'

// .default must be the 1st scope for On-Behalf-Of-Flow combined consent to work properly
// Please see https://learn.microsoft.com/entra/identity-platform/v2-oauth2-on-behalf-of-flow#default-and-combined-consent
var requiredScopes = [ 'api://${authSettings.serverAppId}/.default', 'openid', 'profile', 'email', 'offline_access' ]
var requiredAudiences = [ 'api://${authSettings.serverAppId}' ]

var coreConfig = {
  linuxFxVersion: linuxFxVersion
  alwaysOn: alwaysOn
  ftpsState: ftpsState
  appCommandLine: appCommandLine
  minTlsVersion: '1.2'
  use32BitWorkerProcess: use32BitWorkerProcess
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: appServicePlanSkuName
    capacity: appServicePlanCapacity
    tier: appServicePlanTier
    family: appServicePlanFamily
  }
  properties: {
    reserved: reserved
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  kind: appKind
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: coreConfig
    httpsOnly: true
  }
  identity: { type: 'SystemAssigned' }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties:  union(appSettings,
      {
        APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
      })
  }

  resource configAuth 'config' = if (authSettings.enableAuth) {
    name: 'authsettingsV2'
    properties: {
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'RedirectToLoginPage'
        redirectToProvider: 'azureactivedirectory'
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          registration: {
            clientId: authSettings.clientAppId
            clientSecretSettingName: authSettings.clientSecretSettingName
            openIdIssuer: authSettings.authenticationIssuerUri
          }
          login: {
            loginParameters: [ 'scope=${join(requiredScopes, ' ')}' ]
          }
          validation: {
            allowedAudiences: requiredAudiences
            defaultAuthorizationPolicy: {
              allowedApplications: authSettings.allowedApplications
            }
          }
        }
      }
      login: {
        tokenStore: {
          enabled: true
        }
      }
    }
  }

  resource configLogs 'config' = {
    name: 'logs'
    properties: {
      applicationLogs: { fileSystem: { level: 'Verbose' } }
      detailedErrorMessages: { enabled: true }
      failedRequestsTracing: { enabled: true }
      httpLogs: { fileSystem: { enabled: true, retentionInDays: 1, retentionInMb: 35 } }
    }
    dependsOn: [
      configAppSettings
    ]
  }

  resource basicPublishingCredentialsPoliciesFtp 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource basicPublishingCredentialsPoliciesScm 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
  scope: resourceGroup(applicationInsightsResourceGroup)
}

output id string = appService.id
output identityPrincipalId string = appService.identity.principalId
output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
