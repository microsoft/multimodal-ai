# PowerShell script to create an Azure AI Search skillset
param (
    #The Azure AI Search endpoint
    [parameter(mandatory = $true)][string] $aiSearchEndpoint,

    #Skillset name
    [parameter(mandatory = $true)][string] $skillsetName,

    #Index name
    [parameter(mandatory = $true)][string] $indexName,

    #Azure OpenAI endpoint
    [parameter(mandatory = $true)][string] $azureOpenAIEndpoint,

    #Azure OpenAI deployment id
    [parameter(mandatory = $true)][string] $azureOpenAITextDeploymentId,

    #Azure OpenAI model name to create embeddings
    [parameter(mandatory = $true)][string] $azureOpenAITextModelName,

    #AI services multi-service account key
    [parameter(mandatory = $true)][string] $aiMultiServiceAccountKey,

    #Endpoint for the pdf merge custom skill
    [parameter(mandatory = $true)][string] $pdfMergeCustomSkillEndpoint,

    #ResourceUri of the storage account used for the knowledgestore
    [parameter(mandatory = $true)][string] $knowledgeStoreStorageResourceUri,

    #Name of the storage container used to store pdf page images
    [parameter(mandatory = $true)][string] $knowledgeStoreStorageContainer,

    #App id of the Microsoft Entra ID app to be used for api auth
    [parameter(mandatory = $true)][string] $aadAppId,

    #Json content of the payload template
    [parameter(mandatory = $true)][string] $jsonTemplate
)

$replacements = @{
    "index_name"                                = "$indexName"
    "skillset_name"                             = "$skillsetName"
    "azureOpenAI_endpoint"                      = "$azureOpenAIEndpoint"
    "azureOpenAI_text_deployment_id"            = "$azureOpenAITextDeploymentId"
    "azureOpenAI_text_model_name"               = "$azureOpenAITextModelName"
    "pdf_text_image_merge_skill_url"            = "$pdfMergeCustomSkillEndpoint"
    "cognitiveServices_multiService_accountKey" = "$aiMultiServiceAccountKey"
    "storage_account_resource_uri"              = "$knowledgeStoreStorageResourceUri"
    "storage_account_image_container_name"      = "$knowledgeStoreStorageContainer"
    "aad_app_id"                                = "$aadAppId"
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
    Uri     = "https://$($aiSearchEndpoint).search.windows.net/skillsets/$($skillsetName)?api-version=2024-05-01-preview"
    Headers = @{
        Authorization  = "Bearer $($token)"
        'Content-Type' = 'application/json'
    }
    Body    = $jsonTemplate
    Method  = 'PUT'
}

$Response = Invoke-WebRequest @aiSearchRequest

# Check if the response HTTP status code is not successful
if ($Response.StatusCode -lt 200 -or $Response.StatusCode -ge 300) {
    throw "Request failed with status code: $($Response.StatusCode) - $($Response.StatusDescription)"
}

# Check if the response content is not empty
if (-not [string]::IsNullOrEmpty($Response.Content)) {
    # Parse and output JSON if content is not empty
    [Newtonsoft.Json.Linq.JObject]::Parse($Response.Content).ToString()
}
