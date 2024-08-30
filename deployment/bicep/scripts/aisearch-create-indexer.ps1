# PowerShell script to create a new indexer in Azure AI Search
param (
    #Name of the data source
    [parameter(mandatory = $true)][string] $dataSourceName,

    #The Azure AI Search endpoint
    [parameter(mandatory = $true)][string] $aiSearchEndpoint,

    #index name
    [parameter(mandatory = $true)][string] $indexName,

    #indexer name
    [parameter(mandatory = $true)][string] $indexerName,

    #skillset name
    [parameter(mandatory = $true)][string] $skillsetName,

    #Json content of the payload template
    [parameter(mandatory = $true)][string] $jsonTemplate
)

$replacements = @{
    "datasource_name"                = "$dataSourceName"
    "index_name"                     = "$indexName"
    "indexer_name"                   = "$indexerName"
    "indexer_description"            = "Indexer for auto indexing documents with $($skillsetName)"
    "skillset_name"                  = "$skillsetName"
}

$jsonTemplate = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($jsonTemplate))

# Replace placeholders with their corresponding values
foreach ($key in $replacements.Keys) {
    $placeholder = "\$\{$key\}"
    $jsonTemplate = $jsonTemplate -replace $placeholder, $replacements[$key]
}

$tokenRequest = Get-AzAccessToken -ResourceUrl "https://search.azure.com/"
$token = $tokenRequest.token

$aiSearchRequest = @{
    Uri     = "https://$($aiSearchEndpoint).search.windows.net/indexers/$($indexerName)?api-version=2024-05-01-preview"
    Headers = @{
        Authorization  = "Bearer $($token)"
        'Content-Type' = 'application/json'
    }
    Body    = $jsonTemplate
    Method  = 'PUT'
}


$Response = Invoke-WebRequest @aiSearchRequest

# Check if the response content is not empty
if (-not [string]::IsNullOrEmpty($Response.Content)) {
    # Parse and output JSON if content is not empty
    [Newtonsoft.Json.Linq.JObject]::Parse($Response.Content).ToString()
}
