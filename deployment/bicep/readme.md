Deployment instructions using Bicep

PowerShell

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId <subscriptionId>

.\deploy.ps1 -DeploymentName <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam
```
