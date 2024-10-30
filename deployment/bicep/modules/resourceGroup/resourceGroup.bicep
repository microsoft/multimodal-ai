targetScope = 'subscription'

@sys.description('Azure Region where the resource group will be created.')
param location string

@sys.description('Name of the resource group to be created.')
param resourceGroupName string

@sys.description('Tags you would like to be applied to the resource group.')
param tags object = {}

resource resResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  name: resourceGroupName
  tags: tags
}
output outResourceGroupName string = resResourceGroup.name
output outResourceGroupId string = resResourceGroup.id
output outResourceGroupLocation string = resResourceGroup.location
