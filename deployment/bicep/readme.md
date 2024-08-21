Deployment instructions using Bicep

PowerShell
```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId <subscriptionId>

New-AzSubscriptionDeployment -Name <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam
```
