@sys.description('Location of the Azure AI Search service.')
param location string

@sys.description('Name of the Azure AI Search service.')
param searchName string

@sys.description('Azure AI Search SKU')
@sys.allowed(['basic', 'free', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'])
param skuName string

@sys.description('Azure AI Search partition and replica count.')
param skuCapacity int

@sys.description('Semantic search capability of the search service.')
@sys.allowed(['disabled', 'free', 'standard'])
param semanticSearch string

@sys.description('Hosting mode of the search service.')
@sys.allowed(['default', 'highDensity'])
param hostingMode string = 'default'

@sys.description('Tags you would like to be applied to the resource group.')
param tags object = {}

resource searchResource 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: searchName
  location: location
  tags: tags

  sku: {
    name: skuName    
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hostingMode: hostingMode
    partitionCount: skuCapacity
    replicaCount: skuCapacity
    semanticSearch: semanticSearch
    disableLocalAuth: true
  }
}

output searchResourceId string = searchResource.id
output searchResourcePrincipalId string = searchResource.identity.principalId
output searchResourceName string = searchResource.name
