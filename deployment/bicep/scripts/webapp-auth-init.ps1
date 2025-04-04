Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerAppDisplayName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ServerAppSecretDisplayName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientAppDisplayName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ClientAppSecretDisplayName
)

# Function to create a new application and service principal
function New-ApplicationRegistration {
    param (
        [Hashtable]$RequestApp
    )
    $app = New-MgApplication -BodyParameter $RequestApp
    $objectId = $app.Id
    $clientId = $app.AppId

    # Create a service principal
    $requestPrincipal = @{
        AppId       = $clientId
        DisplayName = $app.DisplayName
    }
    New-MgServicePrincipal -BodyParameter $requestPrincipal | Out-Null

    return @{
        ObjectId = $objectId
        ClientId = $clientId
    }
}

# Function to add a client secret to an application
function Add-ClientSecret {
    param (
        [string]$AppObjectId,
        [string]$DisplayName
    )
    $passwordCredential = @{
        DisplayName = $DisplayName
    }
    $result = Add-MgApplicationPassword -ApplicationId $AppObjectId -PasswordCredential $passwordCredential
    return $result.SecretText
}

# Function to create an application with a client secret based on display name
function Set-ApplicationRegistration {
    param (
        [string]$AppDisplayName,
        [Hashtable]$RequestApp
    )

    $objectId = $null
    $clientId = $null

    # Check if application exists based on display name
    Write-Host "Checking if application '$AppDisplayName' exists"
    $application = Get-MgApplication -Filter "displayName eq '$AppDisplayName'"
    if ($application) {
        throw "Application with display name '$AppDisplayName' already exists. Delete the application and try again."
    }
    else {
        Write-Host "Creating application registration"
        $result = New-ApplicationRegistration -RequestApp $RequestApp
        $objectId = $result.ObjectId
        $clientId = $result.ClientId
    }

    return @{
        ObjectId = $objectId
        ClientId = $clientId
    }
}

# Function to define the initial server application
function New-ServerApp {
    param (
        [string]$DisplayName
    )
    return @{
        DisplayName    = $DisplayName
        SignInAudience = "AzureADMyOrg"
    }
}

# Function to set up server application configuration
function Get-ServerAppConfiguration {
    param (
        [string]$ServerAppId,
        [string]$PermissionScopeId
    )

    $permissionScope = @{
        Id                      = $PermissionScopeId
        AdminConsentDisplayName = "Access Azure Search OpenAI Chat API"
        AdminConsentDescription = "Allows the app to access Azure Search OpenAI Chat API as the signed-in user."
        UserConsentDisplayName  = "Access Azure Search OpenAI Chat API"
        UserConsentDescription  = "Allow the app to access Azure Search OpenAI Chat API on your behalf"
        IsEnabled               = $true
        Value                   = "access_as_user"
        Type                    = "User"
    }

    $apiApplication = @{
        Oauth2PermissionScopes      = @($permissionScope)
        RequestedAccessTokenVersion = 2
        KnownClientApplications     = @()
    }

    $resourceAccesses = @(
        @{ Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"; Type = "Scope" }, # User.Read
        @{ Id = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"; Type = "Scope" }, # email
        @{ Id = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"; Type = "Scope" }, # offline_access
        @{ Id = "37f7f235-527c-4136-accd-4a02d197296e"; Type = "Scope" }, # openid
        @{ Id = "14dad69e-099b-42c9-810b-d002981feec1"; Type = "Scope" }  # profile
    )

    $requiredResourceAccess = @(
        @{
            ResourceAppId  = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
            ResourceAccess = $resourceAccesses
        }
    )

    return @{
        Api                    = $apiApplication
        RequiredResourceAccess = $requiredResourceAccess
        IdentifierUris         = @("api://$ServerAppId")
    }
}

# Function to define the client application
function New-ClientApp {
    param (
        [string]$ServerAppId,
        [string]$ServerAppScopeId,
        [string]$DisplayName
    )

    $requiredResourceAccess = @(
        @{
            ResourceAppId  = $ServerAppId
            ResourceAccess = @(@{ Id = $ServerAppScopeId; Type = "Scope" })
        },
        @{
            ResourceAppId  = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
            ResourceAccess = @(@{ Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"; Type = "Scope" })
        }
    )

    $webApplication = @{
        RedirectUris          = @("http://localhost:50505/.auth/login/aad/callback")
        ImplicitGrantSettings = @{
            EnableIdTokenIssuance     = $true
        }
    }

    $spaApplication = @{
        RedirectUris = @(
            "http://localhost:50505/redirect",
            "http://localhost:5173/redirect"
        )
    }

    return @{
        DisplayName            = $DisplayName
        SignInAudience         = "AzureADMyOrg"
        Web                    = $webApplication
        Spa                    = $spaApplication
        RequiredResourceAccess = $requiredResourceAccess
    }
}

# Function to update server application with known client applications
function Set-KnownClientApplications {
    param (
        [string]$ClientAppId
    )

    return @{
        Api = @{
            KnownClientApplications = @($ClientAppId)
        }
    }
}

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

# Just a self-generated Guid for the self-defined permission scope
$permissionScopeId = "406571c1-e45b-4875-a030-2470f350719d"

Write-Host "Creating server application..."

try {
    $serverApp = New-ServerApp -DisplayName $ServerAppDisplayName
    $serverResult = Set-ApplicationRegistration -AppDisplayName $ServerAppDisplayName -RequestApp $serverApp

    Write-Host "Adding client secret to server application '$ServerAppDisplayName'"
    $serverAppSecret = Add-ClientSecret -AppObjectId $serverResult.ObjectId -DisplayName $ServerAppSecretDisplayName

    Write-Host "Setting up server application configuration..."
    $serverAppConfig = Get-ServerAppConfiguration -ServerAppId $serverResult.ClientId -PermissionScopeId $permissionScopeId
    Update-MgApplication -ApplicationId $serverResult.ObjectId -BodyParameter $serverAppConfig
}
catch {
    Write-Error "Failed to create or update server application: $_"
    exit 1
}

Write-Host "Creating client application..."

try {
    $clientApp = New-ClientApp -ServerAppId $serverResult.ClientId -ServerAppScopeId $permissionScopeId -DisplayName $ClientAppDisplayName
    $clientResult = Set-ApplicationRegistration -AppDisplayName $ClientAppDisplayName -RequestApp $clientApp

    Write-Host "Adding client secret to client application '$ServerAppDisplayName'"
    $clientAppSecret = Add-ClientSecret -AppObjectId $clientResult.ObjectId -DisplayName $ClientAppSecretDisplayName
}
catch {
    Write-Error "Failed to create client application: $_"
    exit 1
}

try {
    Write-Host "Setting up server known client applications..."
    $serverKnownClientApp = Set-KnownClientApplications -ClientAppId $clientResult.ClientId
    Update-MgApplication -ApplicationId $serverResult.ObjectId -BodyParameter $serverKnownClientApp
}
catch {
    Write-Error "Failed to update server known client applications: $_"
    exit 1
}

Write-Host "Authentication setup complete."
Write-Host "Please securely store the application IDs and secrets."
Disconnect-MgGraph

# Output application details
$results = @{
    ServerApp = @{
        ApplicationId              = $serverResult.ClientId
        ObjectId                   = $serverResult.ObjectId
        ServerAppSecretDisplayName = $ServerAppSecretDisplayName
        AppSecret                  = ConvertTo-SecureString $serverAppSecret -AsPlainText -Force
    }
    ClientApp = @{
        ApplicationId              = $clientResult.ClientId
        ObjectId                   = $clientResult.ObjectId
        ClientAppSecretDisplayName = $ClientAppSecretDisplayName
        AppSecret                  = ConvertTo-SecureString $clientAppSecret -AsPlainText -Force
    }
}

return $results
