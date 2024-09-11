targetScope = 'resourceGroup'

@sys.description('Name of the Log Analytics workspace to be created.')
param logAnalyticsWorkspaceName string

@sys.description('SKU of the Log Analytics workspace to be created.')
@allowed(['Free', 'PerGB2018', 'Standalone', 'CapacityReservation', 'PerNode','Premium','LACluster','Standard'])
param logAnalyticsSku string

@sys.description('Retention period in days for the Log Analytics workspace.')
param logAnalyticsRetentionInDays int

@sys.description('Location of the Log Analytics workspace.')
param location string

@sys.description('Tags to apply to the Log Analytics workspace.')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: logAnalyticsSku
    }
    retentionInDays: logAnalyticsRetentionInDays
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
