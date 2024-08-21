targetScope = 'subscription'

// Parameters
@sys.description('Prefix for the resources to be created')
@maxLength(8)
param prefix string = ''

@sys.description('Azure Region where the resources will be created.')
param location string = ''

@sys.description('Specifies the tags which will be applied to all resources.')
param tags object = {}

// Variables
var locationNormalized = toLower(location)

module resourceGroupAI './modules/resourceGroup/resourceGroup.bicep' = {
  name: '${prefix}-ai-rg-${locationNormalized}'
  params: {
    location: location
    resourceGroupName: '${prefix}-ai-rg-${locationNormalized}'
    tags: tags
  }
}
