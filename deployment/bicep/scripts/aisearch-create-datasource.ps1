# PowerShell script to create a new datasource in Azure Cognitive Search
param (
    #The Azure AI Search endpoint
    [parameter(mandatory=$true)][string] $aiSearchEndpoint,

    #Resource Id of the storage account
    [parameter(mandatory=$true)][string] $storageAccountResourceId,

    #Name of the data source
    [parameter(mandatory=$true)][string] $dataSourceName,

    #Name of the table, view, collection, or blob container you wish to index
    [parameter(mandatory=$true)][string] $containerName,

    #Datasource template file in JSON format
    [parameter(mandatory=$true)][string] $jsonTemplate
)

$replacements = @{
    "datasource_name" = $dataSourceName
    "datasource_description" = "Data source for indexing documents from Azure Blob Storage"
    "storage_account_connection_string" = "ResourceId=$storageAccountResourceId;"
    "container_name" = $containerName
}

$jsonTemplate = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($jsonTemplate))

foreach ($key in $replacements.Keys) {
    $placeholder = "\$\{$key\}"
    $jsonTemplate = $jsonTemplate -replace $placeholder, $replacements[$key]
}

$tokenRequest = Get-AzAccessToken -ResourceUrl "https://search.azure.com/"
$token = $tokenRequest.token

$aiSearchRequest = @{
    Uri = "https://$($aiSearchEndpoint).search.windows.net/datasources/$($dataSourceName)?api-version=2024-07-01"
    Headers = @{
        Authorization = "Bearer $($token)"
        'Content-Type' = 'application/json'
        }
    Body = $jsonTemplate
    Method = 'PUT'
    }

$Response = Invoke-WebRequest @aiSearchRequest

# Check if the response content is not empty
if (-not [string]::IsNullOrEmpty($Response.Content)) {
    # Parse and output JSON if content is not empty
    [Newtonsoft.Json.Linq.JObject]::Parse($Response.Content).ToString()
}
