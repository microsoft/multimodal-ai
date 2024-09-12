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
    [string]$TemplateParameterFile
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
    $twoLevelsUpDirectory = (Get-Item $originalDirectory).Parent.Parent.FullName
    $frontEndDirectory = "$twoLevelsUpDirectory/frontend"
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

    # Change to the directory two levels up
    Set-Location $twoLevelsUpDirectory

    # Archive the backend folder to a zip file
    git archive -o $zipPath HEAD:backend

    # Return to the original directory
    Set-Location $originalDirectory

    Write-Verbose "Deploying the web app..."

    # Publish the web app
    Publish-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ArchivePath $zipPath -Timeout 300000 -Force

    # Clean up temporary files
    Remove-Item $zipPath -Force

    Write-Verbose "Web app deployment completed successfully."
}

# Verbose mode switch
$VerbosePreference = 'Continue'

try {
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

    # Validate deployment outputs
    if ($deployment.Outputs.appsResourceGroup -and $deployment.Outputs.webAppName) {
        $webAppRG = $deployment.Outputs.appsResourceGroup.value
        $webAppName = $deployment.Outputs.webAppName.value

        # Call the function to deploy the web app
        Deploy-WebApp -ResourceGroupName $webAppRG -WebAppName $webAppName
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
