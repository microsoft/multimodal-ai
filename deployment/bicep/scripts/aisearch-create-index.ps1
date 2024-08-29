# PowerShell script to create a new index in Azure AI Search
param (
    #The Azure AI Search endpoint
    [parameter(mandatory = $true)][string] $aiSearchEndpoint,

    #index name
    [parameter(mandatory = $true)][string] $indexName,

    #Azure OpenAI endpoint
    [parameter(mandatory = $true)][string] $azureOpenAIEndpoint,

    #Azure OpenAI deployment id
    [parameter(mandatory = $true)][string] $azureOpenAITextDeploymentId,

    #Azure OpenAI model name to create embeddings
    [parameter(mandatory = $true)][string] $azureOpenAITextModelName,

    #Cognitive services endpoint for AI vision
    [parameter(mandatory = $true)][string] $cognitiveServicesEndpoint,

    #Json content of the payload template
    [parameter(mandatory = $true)][string] $jsonTemplate
)

$replacements = @{
    "index_name"                     = "$indexName"
    "azureOpenAI_endpoint"           = "$azureOpenAIEndpoint"
    "azureOpenAI_text_deployment_id" = "$azureOpenAITextDeploymentId"
    "azureOpenAI_text_model_name"    = "$azureOpenAITextModelName"
    "cognitive_services_endpoint"    = "$cognitiveServicesEndpoint"
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
    Uri     = "https://$($aiSearchEndpoint).search.windows.net/indexes/?api-version=2024-05-01-preview"
    Headers = @{
        Authorization  = "Bearer $($token)"
        'Content-Type' = 'application/json'
    }
    Body    = $jsonTemplate
    Method  = 'POST'
}

$Response = Invoke-WebRequest @aiSearchRequest
[Newtonsoft.Json.Linq.JObject]::Parse($Response.Content).ToString()

$output = $Response | ConvertFrom-Json
