metadata description = 'Creates an Azure App Service in an existing Azure App Service plan.'

@sys.description('Name of the App Service Resource.')
param name string

@sys.description('Location of the App Service.')
param location string

@sys.description('Tags you would like to be applied to the resource.')
param tags object = {}

// Reference Properties
@sys.description('Name of the App Insights Resource.')
param applicationInsightsName string

@sys.description('Id of the App Service Plan Resource.')
param appServicePlanId string

@sys.description('Id of the subnet to route traffic through.')
param virtualNetworkSubnetId string

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

// Microsoft.Web/sites/config
@sys.description('Allowed origins for CORS.')
param allowedOrigins array = []

@sys.description('App command line to launch.')
param appCommandLine string

@sys.description('App settings to be used by the application.')
@secure()
param appSettings object = {}

@sys.description('Enables or disables SCM build during deployment.')
param scmDoBuildDuringDeployment bool = false

@sys.description('true to use 32-bit worker process; otherwise, false.')
param use32BitWorkerProcess bool = false

@sys.description('The Client ID of the app used for login.')
param clientAppId string = ''

@sys.description('The app setting name that contains the client secret of the relying party application.')
@secure()
param clientSecretSettingName string

@sys.description('The OpenID Connect Issuer URI that represents the entity which issues access tokens for this application.')
param authenticationIssuerUri string

@allowed([ 'Enabled', 'Disabled' ])
param publicNetworkAccess string = 'Enabled'

@sys.description('Enables unauthenticated access to the app.')
param enableUnauthenticatedAccess bool = false

@sys.description('Enables or disables App service Authentication.')
param disableAppServicesAuthentication bool = false

var enableOryxBuild = contains(kind, 'linux')
var runtimeNameAndVersion = '${runtimeName}|${runtimeVersion}'
var linuxFxVersion = contains(kind, 'linux') ? runtimeNameAndVersion : null
var ftpsState = 'FtpsOnly'
var msftAllowedOrigins = [ 'https://portal.azure.com', 'https://ms.portal.azure.com' ]
var loginEndpoint = environment().authentication.loginEndpoint
var loginEndpointFixed = lastIndexOf(loginEndpoint, '/') == length(loginEndpoint) - 1 ? substring(loginEndpoint, 0, length(loginEndpoint) - 1) : loginEndpoint
var allMsftAllowedOrigins = !(empty(clientAppId)) ? union(msftAllowedOrigins, [ loginEndpointFixed ]) : msftAllowedOrigins
var requiredScopes = [ 'api://${clientAppId}/.default', 'openid', 'profile', 'email', 'offline_access' ]
var requiredAudiences = [ 'api://${clientAppId}' ]

var coreConfig = {
  linuxFxVersion: linuxFxVersion
  alwaysOn: true
  ftpsState: ftpsState
  appCommandLine: appCommandLine
  minTlsVersion: '1.2'
  use32BitWorkerProcess: use32BitWorkerProcess
  cors: {
    allowedOrigins: union(allMsftAllowedOrigins, allowedOrigins)
  }
}

var appServiceProperties = {
  serverFarmId: appServicePlanId
  siteConfig: coreConfig
  httpsOnly: true
  // Always route traffic through the vnet
  // See https://learn.microsoft.com/azure/app-service/configure-vnet-integration-routing#configure-application-routing
  vnetRouteAllEnabled: !empty(virtualNetworkSubnetId)
  virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null
  publicNetworkAccess: publicNetworkAccess
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
    properties: union(appSettings,
      {
        SCM_DO_BUILD_DURING_DEPLOYMENT: string(scmDoBuildDuringDeployment)
        ENABLE_ORYX_BUILD: string(enableOryxBuild)
      },
      runtimeName == 'python' ? { PYTHON_ENABLE_GUNICORN_MULTIWORKERS: 'true' } : {},
      !empty(applicationInsightsName) ? { APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString } : {})
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

  resource configAuth 'config' = if (!(empty(clientAppId)) && !disableAppServicesAuthentication) {
    name: 'authsettingsV2'
    properties: {
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: enableUnauthenticatedAccess ? 'AllowAnonymous' : 'RedirectToLoginPage'
        redirectToProvider: 'azureactivedirectory'
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          registration: {
            clientId: clientAppId
            clientSecretSettingName: clientSecretSettingName
            openIdIssuer: authenticationIssuerUri
          }
          login: {
            loginParameters: [ 'scope=${join(requiredScopes, ' ')}' ]
          }
          validation: {
            allowedAudiences: requiredAudiences
            defaultAuthorizationPolicy: {}
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
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsName)) {
  name: applicationInsightsName
}

output id string = appService.id
output identityPrincipalId string = appService.identity.principalId
output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
