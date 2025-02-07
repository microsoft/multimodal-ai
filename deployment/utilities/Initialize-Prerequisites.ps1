<#
.SYNOPSIS
    Automates the setup of federated credentials, Azure AD applications for GitHub Actions deployments.

.DESCRIPTION
    This script sets up an Azure AD Application and Service Principal for GitHub Actions and ensures role assignments for deployment automation.
    It checks for existing resources and creates them if they do not exist. Additionally, it supports federated credentials for token exchange with GitHub Actions, facilitating secure and automated deployments.

.PARAMETER Prefix
    Prefix for the app registration.

.NOTES
    - The script is intended to be run within a forked repository to avoid conflicts with the main repository.
    - Requires appropriate permissions to create Azure AD applications, management groups, and role assignments.

.EXAMPLE
    .\Initialize-Prerequisites.ps1 -Prefix "MyPrefix"
    Sets up federated credentials, Azure AD applications.
#>
param (
    [parameter(Mandatory = $true)]
    [string]$Prefix
)

#Variables for github actions token exchange and service principal
$AzureAdAppName = "$Prefix-Multimodal-AI-Deploy"
$FederatedName = "GitHubActionsTokenExchange"
$Branch = "main"

# Ensure the user is in a GitHub repository directory
Write-Output "Fetching repository details using Git..."
$originUrl = git remote get-url origin 2>&1
if (-not $originUrl -or $LASTEXITCODE -ne 0) {
    Write-Output "Failed to fetch Git remote URL. Are you in a GitHub repository directory?"
    break
}
if ($originUrl -match "microsoft/multimodal-ai") {
    Write-Output "This script is not intended for running directly from the microsoft/multimodal-ai repository. Run this from your fork."
    break
}

# Extract the repository owner and name from the URL
$Repo = $originUrl -replace '.*github.com[:/]', '' -replace '.git$', ''
Write-Output "Repository detected: $Repo"

# Login to Azure if not already authenticated
Write-Output "Ensuring Azure login..."
if (-not (Get-AzContext)) {
    Connect-AzAccount -UseDeviceAuthentication
}
$subscriptionId = (Get-AzContext).Subscription.Id
$tenantId = (Get-AzContext).Tenant.Id

# Check if Azure AD Application exists
Write-Output "Checking if Azure AD Application exists..."
$existingApp = Get-AzADApplication -Filter "displayName eq '$AzureAdAppName'" -ErrorAction SilentlyContinue
if (-not $existingApp) {
    Write-Output "Azure AD Application not found. Creating a new one..."
    $newApp = New-AzADApplication -DisplayName $AzureAdAppName
    $appClientId = $newApp.AppId
    $appObjectId = $newApp.Id
}
else {
    Write-Output "Azure AD Application already exists. Fetching details..."
    $appClientId = $existingApp.AppId
    $appObjectId = $existingApp.Id
}
Write-Output "Azure AD Application ID: $appClientId"

# Add Federated Credential
Write-Output "Adding Federated Credentials to Azure AD Application..."

# Add support for both pull requests and branch pushes
$subjects = "repo:$($Repo):pull_request", "repo:$($Repo):ref:refs/heads/$($Branch)"
foreach ($subject in $subjects) {

    $parameters = @{
        Name        = "$FederatedName-$($subject.Split(":")[-1] -replace "/", "-")"
        Issuer      = "https://token.actions.githubusercontent.com"
        Subject     = $subject
        Audience    = @("api://AzureADTokenExchange")
        Description = "Federated credentials for the GitHub Actions token exchange to the multimodal-ai repository hosted in $Repo"
    }
    try {
        New-AzADAppFederatedCredential -ApplicationObjectId $appObjectId @parameters -ErrorAction Stop
    }
    catch {
        Write-Warning $_
    }
}

# Create or fetch the Service Principal
Write-Output "Checking for Service Principal..."
$sp = Get-AzADServicePrincipal -ApplicationId $appClientId

if (-not $sp) {
    Write-Output "Service Principal not found. Creating one..."
    $sp = New-AzADServicePrincipal -ApplicationId $appClientId
    Write-Output "Service Principal created. Object ID: $($sp.Id)"
}
else {
    Write-Output "Service Principal already exists. Object ID: $($sp.Id)"
}

Write-Output "Federated Credential added successfully to Entra ID!"

try {
    # Assign owner role to the service principal - we do this at the tenant level to ensure it has access to all subscriptions from the get-go
    New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Owner" -Scope "/subscriptions/$subscriptionId" -ErrorAction SilentlyContinue
}
catch {
    Write-Warning $_
}

# Output success
Write-Output "Federated credential setup complete - save the output below and add it to your GitHub repository secrets"
$GitHubSecrets = @{
    AZURE_CLIENT_ID = $appClientId
    AZURE_TENANT_ID = $tenantId
    AZURE_SUBSCRIPTION_ID = $subscriptionId
}
Write-Output $GitHubSecrets
