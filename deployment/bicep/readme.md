## Deployment instructions using Bicep

### Pre reqs

- PowerShell >= 7.4.5
- Az.* PowerShell modules installed
- Microsoft-Graph PowerShell module installed

### Simple Deployment

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId <subscriptionId>

.\deploy.ps1 -DeploymentName <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam
```

### Bring your own Auth

If you don't have the necessary permissions to create app registrations in Microsoft Entra ID yourself, but someone can handle this for you, you can run the following script after a successful deployment to configure authentication. Be sure to create secrets in the provisioned Azure KeyVault and supply the required parameters:

```powershell
.\webapp-auth-configure.ps1 -ClientAppId <APP_ID_OF_THE_CLIENT_APP> -ServerAppId <APP_ID_OF_THE_SERVER_APP> -ClientSecretNameInKeyVault <KEYVAULT_SECRET_NAME_OF_THE_CLIENT_APP> -ServerSecretNameInKeyVault <KEYVAULT_SECRET_NAME_OF_THE_SERVER_APP> -TenantId <TENANT_ID> -SubscriptionId <SUBSCRIPTION_ID> -ResourceGroupName <RESOURCE_GROUP_NAME> -WebAppName <WEB_APP_NAME> -KeyVaultName <KEYVAULT_NAME>
```

`-ClientAppId` - The application id of the Microsoft Entra ID client app registration

`-ServerAppId` - The application id of the Microsoft Entra ID server app registration

`-ClientSecretNameInKeyVault` - The name of the client app secret in Azure KeyVault

`-ServerSecretNameInKeyVault` - The name of the server app secret in Azure KeyVault

`-TenantId` - The ID of the tenant containing the client and server app registrations

`-SubscriptionId` - The ID of the subscription containing the web app

`-ResourceGroupName` - The name of the resource group containing the web app

`-WebAppName` - The name of the web app to update

`-KeyVaultName` - The name of the Azure KeyVault instance containing the client and server app secrets


### Deploy with Auth enabled

```powershell
.\deploy.ps1 -DeploymentName <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam -EnableAuth
```

Please note that executing the above command will create application registrations in Microsoft Entra ID, which requires you to have the appropriate permissions.

#### Troubleshooting Auth Related Issues

- If your primary tenant restricts the ability to create Entra applications, you'll need to use a separate tenant to create the Entra applications. You can create a new tenant by following [these instructions](https://learn.microsoft.com/entra/identity-platform/quickstart-create-new-tenant).
- It's possible that your tenant admin has placed a restriction on consent to apps with [unverified publishers](https://learn.microsoft.com/entra/identity-platform/publisher-verification-overview). In this case, only admins may consent to the client and server apps, and normal user accounts are unable to use the login system until the admin consents on behalf of the entire organization.
- It's possible that your tenant admin requires [admin approval of all new apps](https://learn.microsoft.com/entra/identity/enterprise-apps/manage-consent-requests). Regardless of whether you select the delegated or admin permissions, the app will not work without tenant admin consent. See this guide for [granting consent to an app](https://learn.microsoft.com/entra/identity/enterprise-apps/grant-admin-consent?pivots=portal).
