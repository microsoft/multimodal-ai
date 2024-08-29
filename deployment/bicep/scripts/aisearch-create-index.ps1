# PowerShell script to create a new index in Azure AI Search
param (
    #The Azure AI Search endpoint
    [parameter(mandatory=$true)][string] $aiSearchEndpoint,
    
    #index name Id of the storage account
    [parameter(mandatory=$true)][string] $indexName,
    
    #Azure OpenAI endpoint
    [parameter(mandatory=$true)][string] $azureOpenAIEndpoint,
    
    #Azure OpenAI deployment id
    [parameter(mandatory=$true)][string] $azureOpenAITextDeploymentId,

    #Azure OpenAI model name to create embeddings
    [parameter(mandatory=$true)][string] $azureOpenAITextModelName,

    #Name of the table, view, collection, or blob container you wish to index
    [parameter(mandatory=$true)][string] $cognitiveServicesEndpoint
)

$jsonTemplatePath = "..\..\library\index_template.json"

$replacements = @{
    "index_name"                     = "$indexName"
    "azureOpenAI_endpoint"           = "$azureOpenAIEndpoint"
    "azureOpenAI_text_deployment_id" = "$azureOpenAITextDeploymentId"
    "azureOpenAI_text_model_name"    = "$azureOpenAITextModelName"
    "cognitive_services_endpoint"    = "$cognitiveServicesEndpoint"
}

# Read the JSON template file
$jsonContent = Get-Content -Path $jsonTemplatePath -Raw

# Replace placeholders with their corresponding values
foreach ($key in $replacements.Keys) {
    $placeholder = "\$\{$key\}"
    $jsonContent = $jsonContent -replace $placeholder, $replacements[$key]
}

$tokenRequest = Get-AzAccessToken -ResourceUrl "https://search.azure.com/"
$token = $tokenRequest.token

$aiSearchRequest = @{
    Uri = "https://$($aiSearchEndpoint).search.windows.net/indexes?api-version=2024-07-01"
    Headers = @{
        Authorization = "Bearer $($token)"
        'Content-Type' = 'application/json'
        }
    Body = $jsonContent
    Method = 'POST'
    }

$Response = Invoke-WebRequest @aiSearchRequest
[Newtonsoft.Json.Linq.JObject]::Parse($Response.Content).ToString()

$output = $Response | ConvertFrom-Json
