Deployment instructions using Bicep

PowerShell

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId <subscriptionId>

.\deploy.ps1 -DeploymentName <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam
```

OR if you want to deploy with Auth enabled run this command like this:

```powershell
.\deploy.ps1 -DeploymentName <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam -EnableAuth
```

Please note that executing the above command will create application registrations in Microsoft Entra ID, which requires you to have the appropriate permissions.
