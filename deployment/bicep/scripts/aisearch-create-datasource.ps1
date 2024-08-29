# PowerShell script to create a new datasource in Azure Cognitive Search
param (
    #The Azure AI Search endpoint
    [parameter(mandatory=$true)][string] $aiSearchEndpoint,

    #Resource Id of the storage account
    [parameter(mandatory=$true)][string] $storageAccountResourceId,

    #Name of the data source
    [parameter(mandatory=$true)][string] $dataSourceName,

    #Supported data source type. Supported values include: "azureblob", "azuretable", "azuresql", "cosmosdb"
    [parameter(mandatory=$true)][string] $dataSourceType,

    #Name of the table, view, collection, or blob container you wish to index
    [parameter(mandatory=$true)][string] $containerName
)

$tokenRequest = Get-AzAccessToken -ResourceUrl "https://search.azure.com/"
$token = $tokenRequest.token

$body = @"
{
    "name": "$dataSourceName",
    "type": "$dataSourceType",
    "credentials": {
        "connectionString": "ResourceId=$storageAccountResourceId;"
    },
    "container": {
        "name": "$containerName"
    },
    "dataDeletionDetectionPolicy": {
      "@odata.type": "#Microsoft.Azure.Search.NativeBlobSoftDeleteDeletionDetectionPolicy"
    }
}
"@

$aiSearchRequest = @{
    Uri = "https://$($aiSearchEndpoint).search.windows.net/datasources?api-version=2024-07-01"
    Headers = @{
        Authorization = "Bearer $($token)"
        'Content-Type' = 'application/json'
        }
    Body = $body
    Method = 'POST'
    }

$Response = Invoke-WebRequest @aiSearchRequest
[Newtonsoft.Json.Linq.JObject]::Parse($Response.Content).ToString()

$output = $Response | ConvertFrom-Json
