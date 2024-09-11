@sys.description('Name of the App Service Resource.')
param name string

@sys.description('Location of the App Service.')
param location string

@sys.description('Tags you would like to be applied to the resource.')
param tags object = {}

@sys.description('Id of the App Service Plan Resource.')
param appServicePlanId string

// Runtime Properties
@sys.description('Runtime to be used.')
@allowed([
  'dotnet', 'dotnetcore', 'dotnet-isolated', 'node', 'python', 'java', 'powershell', 'custom'
])
param runtimeName string

@sys.description('Specific runtime verion to be used.')
param runtimeVersion string

@sys.description('Kind of the App Service Plan Resource: https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md#app-service-resource-kind-reference')
param kind string = 'app,linux'

@sys.description('Specifies if the runtime should be always on')
param alwaysOn bool = true

@sys.description('App command line to launch.')
param appCommandLine string

@sys.description('App settings to be used by the application.')
@secure()
param appSettings object = {}

@sys.description('true to use 32-bit worker process; otherwise, false.')
param use32BitWorkerProcess bool = false

var runtimeNameAndVersion = '${runtimeName}|${runtimeVersion}'
var linuxFxVersion = contains(kind, 'linux') ? runtimeNameAndVersion : null
var ftpsState = 'FtpsOnly'

var coreConfig = {
  linuxFxVersion: linuxFxVersion
  alwaysOn: alwaysOn
  ftpsState: ftpsState
  appCommandLine: appCommandLine
  minTlsVersion: '1.2'
  use32BitWorkerProcess: use32BitWorkerProcess
}

var appServiceProperties = {
  serverFarmId: appServicePlanId
  siteConfig: coreConfig
  httpsOnly: true
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: appServiceProperties
  identity: { type: 'SystemAssigned' }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: appSettings
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

output id string = appService.id
output identityPrincipalId string = appService.identity.principalId
output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
