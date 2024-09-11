@sys.description('Name of the App Service Plan Resource.')
param name string

@sys.description('Location of the App Service Plan.')
param location string

@sys.description('Tags you would like to be applied to the resource.')
param tags object = {}

@sys.description('Kind of the App Service Plan Resource: https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md#app-service-resource-kind-reference')
param kind string = ''

@sys.description('Description of a SKU for a scalable resource.')
param sku object

var reserved = contains(toLower(kind), 'linux')

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: kind
  properties: {
    reserved: reserved
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
