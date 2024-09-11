targetScope = 'resourceGroup'

@sys.description('Name of the Application Insights instance to be created.')
param appInsightsName string

@sys.description('Resource ID of the Log Analytics workspace to be associated with the Application Insights instance.')
param logAnalyticsWorkspaceId string

@sys.description('Location of the Application Insights instance.')
param location string

@sys.description('Kind of the Application Insights instance.')
param kind string = 'web'

@sys.description('Application type of the Application Insights instance.')
param applicationType string = 'web'

@sys.description('Tags to apply to the Application Insights instance.')
param tags object = {}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

output appInsightsResourceId string = appInsights.id
