## Deployment instructions using Bicep

### Requirements
- [PowerShell >= 7.4.5](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.4)
- [Bicep CLI > 0.16.1](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)
- [Az.* PowerShell modules installed](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-13.0.0)
- [Microsoft-Graph PowerShell module installed](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0)
- [Node.js v18.17 or later and npm v9.6 or later](https://nodejs.org/en/download/package-manager)

### Simple Deployment

```powershell
Connect-AzAccount
Set-AzContext -SubscriptionId <subscriptionId>

.\deploy.ps1 -DeploymentName <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam
```

#### Parameter File
In addition to the deployment parameters specified in the above script, it is essential to manage and modify the ***multimodal-ai.bicepparam*** parameter file according to your preferences.
 It is important to specify the prefix to provide uniqueness to the resources that will be created.
Also each AI service has separate location and SKU parameters that need to be configured, as it may be necessary to alter of a specific service the location for various reasons. We recommend locating all services within the same region, since multi modal source files are typically large and may incur significant egress/ingress charges between regions.

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

> [!TIP]
>
> To create secrets in Azure KeyVault with RBAC enabled, you need to have the *"[Key Vault Secrets Officer](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations)"* permission on the KeyVault instance.


### Deploy with Auth enabled

```powershell
.\deploy.ps1 -DeploymentName <DeploymentName> -Location <Location> -TemplateFile ./multimodal-ai.bicep -TemplateParameterFile ./multimodal-ai.bicepparam -EnableAuth
```

Please note that executing the above command will create application registrations in Microsoft Entra ID, which requires you to have the appropriate permissions.

### Using the Solution

1. **Upload Your PDF Documents**
   Begin by uploading your PDF files to the blob storage container. By default, the container is named `docs`. Ensure your documents are correctly placed here for indexing.

2. **Run the Indexer**
   To process your uploaded PDF files in your Azure AI Search instance:
   - Go to the Azure AI Search instance and navigate to the **Search management** section.
   - Select **Indexers** and click on the name of your indexer.
   - On the indexer's details page, click **Run** to start the indexing process.
   - The time required for the indexer to complete depends on the number and size of the documents. Typically, this can range from a few seconds to several minutes. Use the **Refresh** button on the details page to monitor progress.

3. **Interact with the Web Application**
   Once the indexer has successfully completed, open the web application and start asking your questions. The indexed data will be ready to support your queries.
   > [!TIP]
   >
   > In the web application's **Developer Settings** section, you can explore various search modes and experiment with a range of other configuration options.

### Troubleshooting

#### Deployment

- *Cannot retrieve the dynamic parameters for the cmdlet. Please use bicep 0.16.1 or higher.* This problem requires you updating the Bicep CLI installation. Check your current version with   `bicep --version` and `az bicep version`. If you have multiple versions installed  you may need to do changes in PATH environment variable. For further guidance in such a problem refer to the [official troubleshooting guidance for multiple versions of bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/installation-troubleshoot#multiple-versions-of-bicep-cli-installed)
- *This subscription cannot create CognitiveServices until you agree to Responsible AI terms for this resource. You can agree to Responsible AI terms by creating a resource through the Azure Portal then trying again.* If your subscription is new or you had no Azure AI resources deployed previously there is a manual step that you need to perform first. You do not have to deploy the services but go to the services deployment experience and agree to Responsible AI terms.

#### Troubleshooting Auth Related Issues

- If your primary tenant restricts the ability to create Entra applications, you'll need to use a separate tenant to create the Entra applications. You can create a new tenant by following [these instructions](https://learn.microsoft.com/entra/identity-platform/quickstart-create-new-tenant).
- It's possible that your tenant admin has placed a restriction on consent to apps with [unverified publishers](https://learn.microsoft.com/entra/identity-platform/publisher-verification-overview). In this case, only admins may consent to the client and server apps, and normal user accounts are unable to use the login system until the admin consents on behalf of the entire organization.
- It's possible that your tenant admin requires [admin approval of all new apps](https://learn.microsoft.com/entra/identity/enterprise-apps/manage-consent-requests). Regardless of whether you select the delegated or admin permissions, the app will not work without tenant admin consent. See this guide for [granting consent to an app](https://learn.microsoft.com/entra/identity/enterprise-apps/grant-admin-consent?pivots=portal).

### Delete Deployment

Depending the purpose of deployment purging the deployed assets might  become necessary. Since bicep does not have a state file like terraform, we can do this by specifically targeting the resource groups.

The script has two steps, first controlling the resource groups targeted for deletion, second for performing the delete operation. IT requires you to provide prefix variable with the same value you used for  **prefix** parameter in ***multimodal-ai.bicepparam*** file.

#### Control Script

```powershell
# Set your prefix variable with the same value you used for
# prefix parameter in multimodal-ai.bicepparam file
$prefix="mmai01"

#List all matching resource groups to check if correct resource groups are targeted
az group list --query "[?contains(name,'$($prefix)')]" --output table
```

#### Purge Script
```powershell
# Set your prefix variable with the same value you used for
# prefix parameter in multimodal-ai.bicepparam file
$prefix="mmai01"
ForEach ($rgList in $(az group list --query "[?contains(name,'$($prefix)') == ``true``].name" --output tsv))
    {
        echo "deleting resource group  $rgList"
        az group delete --resource-group $rgList --yes
    }
```
