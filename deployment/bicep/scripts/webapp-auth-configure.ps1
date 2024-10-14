Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientAppId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerAppId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientSecretKeyVaultName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerSecretKeyVaultName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName,

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$WebAppName
)

function Get-AccessToken {
    try {
        $tokenRequest = Get-AzAccessToken -ResourceUrl "https://management.azure.com/"
        return $tokenRequest.Token
    }
    catch {
        throw "Failed to retrieve access token: $_"
    }
}

function Update-WebAppAuth {
    param (
        [string]$Token,
        [string]$SubscriptionId,
        [string]$ResourceGroupName,
        [string]$WebAppName,
        [string]$AuthConfig
    )

    $webAppAuthUpdateRequest = @{
        Uri     = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$WebAppName/config/authsettingsV2?api-version=2024-04-01"
        Headers = @{
            Authorization  = "Bearer $($Token)"
            'Content-Type' = 'application/json'
        }
        Body    = $AuthConfig
        Method  = 'PUT'
    }

    try {
        $response = Invoke-WebRequest @webAppAuthUpdateRequest
        return $response
    }
    catch {
        throw "Failed to update Web App auth settings: $_"
    }
}

# Fetch and replace values in the template
$replacements = @{
    "server_app_id" = "$ServerAppId"
    "client_app_id" = "$ClientAppId"
    "tenant_id"     = "$TenantId"
}
$jsonTemplate = Get-Content ../../library/auth_configuration.json -Raw
foreach ($key in $replacements.Keys) {
    $placeholder = "\$\{$key\}"
    $jsonTemplate = $jsonTemplate -replace $placeholder, $replacements[$key]
}

# Obtain Access Token
Write-Output "Obtaining access token..." 
$token = Get-AccessToken

# Update the Web App Authentication Settings
Write-Output "Updating Web App authentication settings..."
$response = Update-WebAppAuth -Token $token -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -WebAppName $WebAppName -AuthConfig $jsonTemplate

# Verify the response
if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
    throw "Failed to update Web App auth settings. Status code: $($response.StatusCode)"
}

# Update Web App settings

$webapp=Get-AzWebApp -ResourceGroupName $ResourceGroupName  -Name $WebAppName
$appSettings=$webapp.SiteConfig.AppSettings

$newAppSettings = @{
    "AZURE_USE_AUTHENTICATION"                 = "true"
    "AZURE_SERVER_APP_ID"                      = $ServerAppId
    "AZURE_CLIENT_APP_ID"                      = $ClientAppId
    "AZURE_SERVER_APP_SECRET"                  = "@Microsoft.KeyVault(VaultName=$KeyVaultName;SecretName=$ServerSecretKeyVaultName)"
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = "@Microsoft.KeyVault(VaultName=$KeyVaultName;SecretName=$ClientSecretKeyVaultName)"
    "AZURE_ENFORCE_ACCESS_CONTROL"             = "false"
    "AZURE_ENABLE_UNAUTHENTICATED_ACCESS"      = "false"
}

ForEach ($item in $appSettings) {  
    if (-not $newAppSettings.ContainsKey($item.Name)) {
        $newAppSettings[$item.Name] = $item.Value
    }
} 

Write-Output "Updating Web App settings..."
Set-AzWebApp -AppSettings $newAppSettings -Name $WebAppName -ResourceGroupName $ResourceGroupName

Write-Output "Web app authentication configuration completed successfully."
