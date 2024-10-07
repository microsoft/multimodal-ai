param (
    [Parameter(Mandatory = $true)]
    [string]$DeploymentName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })] # Ensures file exists
    [string]$TemplateFile,

    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })] # Ensures file exists
    [string]$TemplateParameterFile,

    [switch]$EnableAuth = $false
)

# Function to deploy the web app
function Deploy-WebApp {
    param (
        [string]$ResourceGroupName,
        [string]$WebAppName
    )

    Write-Verbose "Triggering web app deployment..."
    Write-Verbose "Using resource group: $ResourceGroupName"
    Write-Verbose "Using app service resource: $WebAppName"

    $originalDirectory = Get-Location
    $projectRootDirectory = (Get-Item $originalDirectory).Parent.Parent.FullName
    $frontEndDirectory = "$projectRootDirectory/frontend"
    $backEndDirectory = "$projectRootDirectory/backend"
    $zipPath = "$originalDirectory/backend.zip"

    # Change to the frontend directoty to build the static frontend
    Set-Location $frontEndDirectory

    Write-Verbose "Installing dependencies and building the web app..."

    npm install
    if ($LASTEXITCODE -ne 0) {
        throw "Restoring frontend npm packages"
    }

    npm run build
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to build frontend"
    }

    # Change to the directory root
    Set-Location $projectRootDirectory

    # Archive the backend folder to a zip file. Will only compress committed files not part of .gitignore
    git archive -o $zipPath HEAD:backend

    # Now add generated files not tracked by git
    Compress-Archive -Path "$backEndDirectory/static" -Update -DestinationPath $zipPath

    # Return to the original directory
    Set-Location $originalDirectory

    Write-Verbose "Deploying the web app..."

    # Publish the web app
    Publish-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ArchivePath $zipPath -Timeout 300000 -Force

    # Clean up temporary files
    Remove-Item $zipPath -Force

    Write-Verbose "Web app deployment completed successfully."
}

# Function to deploy custom skills
function Deploy-CustomSkills {
    param (
        [string]$ResourceGroupName,
        [string]$FunctionAppName
    )

    Write-Verbose "Triggering function app deployment..."
    Write-Verbose "Using resource group: $ResourceGroupName"
    Write-Verbose "Using function app resource: $FunctionAppName"

    $originalDirectory = Get-Location
    $projectRootDirectory = (Get-Item $originalDirectory).Parent.Parent.FullName
    $customSkillName = "pdf_text_image_merge_skill"
    $customSkillDirectory = "custom_skills/$customSkillName"
    $zipPath = "$originalDirectory/$customSkillName.zip"

    # Change to the directory root
    Set-Location $projectRootDirectory

    # Archive the backend folder to a zip file. Will only compress committed files not part of .gitignore
    git archive -o $zipPath HEAD:$customSkillDirectory

    # Return to the original directory
    Set-Location $originalDirectory

    Write-Verbose "Deploying the function app..."

    # Publish the web app
    Publish-AzWebApp -ResourceGroupName $ResourceGroupName -Name $FunctionAppName -ArchivePath $zipPath -Timeout 300000 -Force

    # Clean up temporary files
    Remove-Item $zipPath -Force

    Write-Verbose "Function app deployment completed successfully."
}

# Verbose mode switch
$VerbosePreference = 'Continue'

try {

    $deployment = $null

    if ($EnableAuth) {
        Write-Verbose "Setting up authentication..."

        $authDetails = . "$PSScriptRoot/scripts/webapp-auth-init.ps1" `
            -ServerAppDisplayName "mmai-server-app" `
            -ClientAppDisplayName "mmai-client-app" `
            -ServerAppSecretDisplayName "mmai-server-app-secret" `
            -ErrorAction Stop `
            -ErrorVariable deploymentError

        $params = @{
            isAuthEnabled        = $true
            enforceAccessControl = $false
            serverApp            = @{
                appId         = $authDetails.ServerApp.ApplicationId
                appSecretName = $authDetails.ServerApp.ServerAppSecretDisplayName
                appSecret     = ""
            }
            clientApp            = @{
                appId = $authDetails.ClientApp.ApplicationId
            }
        }

        if ('AppSecret' -in $results.ServerApp.Keys) {
            $params.serverApp.appSecret = ConvertFrom-SecureString $authDetails.ServerApp.AppSecret
        } else {
            Write-Verbose "The Secret property is not present for the server app. Assuming the app registration already exists."
        }

        Write-Verbose "Deploying infrastructure..."

        # Execute the deployment command with error handling
        $deployment = New-AzSubscriptionDeployment `
            -Name $DeploymentName `
            -Location $Location `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $TemplateParameterFile `
            -authSettings $params `
            -Verbose `
            -ErrorAction Stop `
            -ErrorVariable deploymentError

    }
    else {
        Write-Verbose "Deploying infrastructure..."

        # Execute the deployment command with error handling
        $deployment = New-AzSubscriptionDeployment `
            -Name $DeploymentName `
            -Location $Location `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $TemplateParameterFile `
            -Verbose `
            -ErrorAction Stop `
            -ErrorVariable deploymentError
    }

    # Validate deployment outputs
    if ($deployment.Outputs.appsResourceGroup -and $deployment.Outputs.webAppName -and $deployment.Outputs.functionAppName) {
        $webAppRG = $deployment.Outputs.appsResourceGroup.value
        $webAppName = $deployment.Outputs.webAppName.value
        $functionAppName = $deployment.Outputs.functionAppName.value

        # Call the function to deploy the web app
        Deploy-WebApp -ResourceGroupName $webAppRG -WebAppName $webAppName
        Deploy-CustomSkills -ResourceGroupName $webAppRG -FunctionAppName $functionAppName
    }
    else {
        throw "Deployment output is incomplete. Please check your template."
    }
}
catch {
    Write-Host "Deployment failed. Details:"
    Write-Host $_.Exception.Message
    if ($deploymentError) {
        Write-Host "Deployment error details: $deploymentError"
    }
}
