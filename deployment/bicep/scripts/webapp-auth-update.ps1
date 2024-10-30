Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientObjectId,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$BackendUri
)

Write-Host "Setting up authentication"

# Connect to Microsoft Graph
try {
    $tokenRequest = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"
    $token = $tokenRequest.token
    Connect-MgGraph -AccessToken ($token | ConvertTo-SecureString -AsPlainText -Force)
}
catch {
    Write-Error "Failed to connect to Microsoft Graph: $_"
    exit 1
}

try {
    $app = @{
        PublicClient = @{
            RedirectUris = @()
        }
        Spa          = @{
            RedirectUris = @(
                "http://localhost:50505/redirect",
                "http://localhost:5173/redirect",
                "$BackendUri/redirect"
            )
        }
        Web          = @{
            RedirectUris = @(
                "$BackendUri/.auth/login/aad/callback"
            )
        }
    }

    Write-Host $app.Spas.RedirectUris

    Update-MgApplication -ApplicationId $ClientObjectId -BodyParameter $app
}
catch {
    Write-Error "Failed to update the client application: $_"
    exit 1
}

Disconnect-MgGraph
