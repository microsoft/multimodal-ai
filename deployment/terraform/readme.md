# Deploying Multimodal AI Platform Using Terraform

## Requirements

- Terraform v1.6 or later
  - Check version
  ```bash
  terraform --version
  ```
  - Update version
    - Download and update from [Terraform website](https://www.terraform.io/downloads.html)
- Node.js v18.17  or later and Npm v9.6 or later
  - Check version
  ```bash
  node -v
  npm -v
  ```
  - Update version
    - Download and update from [Node.JS website](https://nodejs.org/en/download/package-manager)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) v2.5 or later
  - Check version
  ```bash
  az --version
  ```
  - Update version
    - Download and update from [Azure CLI website](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure CLI Extension authV2](https://docs.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview?view=azure-cli-latest)
  - Check version
    ```bash
    az extension list --output table
    ```
  - Update/Install version
    ```bash
    az extension add --name authV2
    ```

- Contributor role in the subscription specified in the **terraform.tfvars** file
- When authenticated with a user principal, you need one of the following directory roles to be able to create application registration : Application Administrator or Global Administrator
- When authenticated with a service principal, it needs  one of the following application roles: Application.ReadWrite.OwnedBy or Application.ReadWrite.All. Additionally, you may need the User.Read.All application role when including user principals in the owners property.

## Limitations
This solution uses latest functionality for most services provided. However, this functionality is only available at certain regions for some of the services. You may determine location for services using following parameters in **terraform.tfvars** file:

- location: This is used as the default location for all services not specified below
- openai_service_location
- search_service_location (This is also used to deploy cognitive service (Azure AI services multi-service account) used by search service  )
- form_recognizer_service_location
- computer_vision_service_location

Before determining your deployment topology (e.g. where to deploy services), be aware of following restrictions.

- openai_service_location: This is the location where the OpenAI service is deployed. This must be a region that supports gpt-35-turbo,0613 models for OpenAI. Valid values at the time this code published are:
  - australiaeast
  - canadaeast
  - eastus
  - eastus2
  - francecentral
  - japaneast
  - northcentralus
  - swedencentral
  - switzerlandnorth
  - uksouth

  Regions that support gpt-35-turbo,0613 models are published [here](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models#gpt-35-models)

- form_recognizer_service_location: This is the location where the Form Recognizer cognitive service is deployed. This must be a region that supports API 2024-07-31-preview. Valid values at the time this code published are:
  - eastus
  - northcentralus
  - westeurope
  - westus2

  Regions that support API 2024-07-31-preview are published [here](https://learn.microsoft.com/en-us/azure/cognitive-services/form-recognizer/overview#supported-apis)

- computer_vision_service_location: This is the location where the Form Recognizer cognitive service is deployed. This must be a region that supports Multimodal embeddings. Valid values at the time this code published are:
  - eastus
  - westus
  - westus2
  - francecentral
  - northeurope
  - westeurope
  - swedencentral
  - switzerlandnorth
  - australiaeast
  - southeastasia
  - koreacentral
  - japaneast

  Regions that support Multimodal embeddings are published [here](https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/overview-image-analysis?tabs=4-0#region-availability)

## Deployment

- Edit and set mandatory variables in **terraform.tfvars** file
  - subscription_id
  - location
  - environment_name

- You can also change any of the default values provided in **terraform.tfvars** file. If a value is not provided for resource names, a value will be created automatically. One special note about **appservice_plan_sku** variable is that if you set this to "B1" or "B2", terraform code will automatically upgrade the SKU to B3 for the duration of code deployment and revert it back when deployment is complete. This is in order to avoid possible 504 Gateway Timeout errors during deployment.

- Login to CLI, note that this step is required if you are using Azure Cloud Shell
```bash
az login
```

- Ensure that you are logged on to the correct tenant. Following command should succeed without any errors.
```bash
az account set --subscription <subscription_name_or_id>
```

- Run Terraform command line

```bash
cd deployment/terraform
terraform init
terraform apply
```

- When terraform configuration finishes, it will output the following information:
  - tenant_id : Tenant ID where deployment is done.
  - subscription_id : Subscription ID where deployment is done.
  - resource_group_name : The resource group created (default name similar to "rg-mmai-12345678").
  - multimodal_ai_web_site: The web site URL for the Multimodal AI web application.
  - documents_source_storage : Name of the storage account to store documents to be indexed.
  - documents_source_container : Name of the container to store documents to be indexed.
  - skills_function_appregistration_client_id : Application ID of the Azure Function App registration in Azure Active Directory.
  - webapp_client_appregistration_client_id   : Application ID of the backend web app's client app registration in Azure Active Directory, used to support Azure Entra ID authentication for web app.
  - webapp_server_appregistration_client_id   : Application ID of the backend web app's server app registration in Azure Active Directory, used to support Azure Entra ID authentication for web app.
  - cleanup_command : Command to delete the resources group and app registration created by the deployment.

## Using the solution

- Navigate to the web site URL provided in the terraform output variable **multimodal_ai_web_site**. Note that if you used a smaller SKU for web app (e.g. B1 (default) or B2), it may take a few minutes for the web app to start. If you see a 504.0 GatewayTimeout error please refresh the web site .

- In order to index and use your own documents for the solution follow instructions provided in section [Indexing Documents](#indexing-documents).

## Handling Errors During Deployment

### "Failed to connect to MSI" error

You may get following error during deployment because you have not logged in or your token has expired.

```bash
│ Error: retrieving static website properties for Storage Account (Subscription: "00000000-0000-0000-0000-000000000000"
│ Resource Group Name: "rg-mmai-XXXXXXXX"
│ Storage Account Name: "stXXXXXXXX"): executing request: authorizing request: running Azure CLI: exit status 1: ERROR: Failed to connect to MSI. Please make sure MSI is configured correctly.
│ Get Token request returned: <Response [400]>
│
│   with module.storage.azurerm_storage_account.storage,
│   on modules/storage/storage.tf line 1, in resource "azurerm_storage_account" "storage":
│    1: resource "azurerm_storage_account" "storage" {
```

Run "az login" command and try again. Note that you have toi run az login if you are running deployment from Azure Cloud Shell

```bash
az login
```

You may use following command to display signed in user

```bash
az ad signed-in-user show
```

### "unrecognized arguments" error

If you receive an error that is similar to output below, this is because authV2 extension is not installed. Install the extension using the command provided in the [Requirements](#requirements) section and try again.

```bash
Error: local-exec provisioner error
  with null_resource.update_function_app_allowed_applications,
  on service.tf line 192, in resource "null_resource" "update_function_app_allowed_applications":
 192:   provisioner "local-exec" {
.
.
ERROR: unrecognized arguments: --set identityProviders.azureActiveDirectory.validation.defaultAuthorizationPolicy.allowedApplications=[XXXXXXXXXXXXXXXXXXXXXXX]
```

### 504 Gateway Timeout Error

When you deploy compute resources (such as webapp) with minimum capacity, sometimes deployment fails with 504 errors because the the destination server is not responding within the timeout period.

```bash
module.backend_webapp.null_resource.linux_webapp_deployment[0] (local-exec): WARNING: Deployment endpoint responded with status code 504
module.backend_webapp.null_resource.linux_webapp_deployment[0] (local-exec): ERROR: An error occured during deployment. Status Code: 504, Details: 504.0 GatewayTimeout

In such cases, instead of deleting and repeating entire deployment you can simply redeploy the webapp using following commands.

```powershell
Compress-Archive -Path ..\..\backend\* -DestinationPath <archive name>.zip
az webapp deployment source config-zip --resource-group <resource group name>> --name <backend webapp name> --src <archive name>.zip --timeout 900
```
e.g.
```powershell
Compress-Archive -Path ..\..\backend\* -DestinationPath backend.zip
az webapp deployment source config-zip --resource-group rg-mmai-00000000 --name backend-00000000 --src backend.zip --timeout 900
```

## Indexing Documents

- Upload documents to the storage account (documents_source_storage) and container (documents_source_container) as provided in the terraform output.
- Navigate to Azure AI Search resource created (default name similar to "srch-12345678")
- Navigate to int indexer created (default name similar to "srch-inder-12345678")
- Click on "Run" to start indexing the documents and wait for process to finish.
- Access the web application using the URL provided in the terraform output variable **multimodal_ai_web_site**.

## Configuring authentication

By default web application is deployed with Azure Active Directory authentication enabled. Deployment configuration also creates client and server app registrations in Azure Entra ID. However, if you don't have privileges to create app registrations, you can either have your Entra ID admin to create app registrations for you or disable authentication.

### Manually creating app registrations

#### Server app registration for Web App

- Navigate to Microsoft Entra ID in Azure Portal
- Click on "Manage" > "App registrations" and then "New registration"
- Provide a name for the app registration (e.g. mmai-serverapp)
- Select "Accounts in this organizational directory only" for supported account types
- Click "Register" to create the app registration
- Take note of the "Application (client) ID" from the app registration
- After registration is completed navigate to "Manage" > "App registrations" > mmai-serverapp > "Manage" > "API permissions"
- Add following delegated permissions for "Microsoft.Graph"
  - email
  - offline_access
  - openid
  - profile
  - User.Read
- Navigate to "Manage" > "App registrations" > mmai-serverapp > "Manage" > "Expose an API"
- Click "Add a scope"
- Click "Save and continue" to accept Application ID URI given (it should look like api://XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)
- Enter following values
  - Scope name: **access_as_user**
  - Who can consent: **Admins and users**
  - Admin consent display name: **Access Azure Search OpenAI Chat API**
  - Admin consent description: **Allows the app to access Azure Search OpenAI Chat API as the signed-in user.**
  - User consent display name: **Access Azure Search OpenAI Chat API**
  - User consent description: **Allow the app to access Azure Search OpenAI Chat API on your behalf.**
  - State: Enabled
  - Click "Add scope" to create the scope
- Navigate to "Manage" > "App registrations" > mmai-serverapp > "Manage" > "Certificates & secrets"
- Click "New client secret" to create a new secret
- Enter a description (e.g serverapp-secret) and click "Add"
- Take note of the secret value before navigating away from the page, because it will not be shown again
- After you complete next step [Client app registration for Web App](#client-app-registration-for-web-app), navigate back to "Server App Registration (mmai-serverapp)" > "Manage" > "Manifest"
- Update **api.knownClientApplications** to include Web App Client App Registration Client ID
```json
	"api": {
		.
    .
		"knownClientApplications": [
			"<Client app registration application (client) ID for Web App>"
		],
    .
    .
  }
  ```

#### Client app registration for Web App

- Navigate to Microsoft Entra ID in Azure Portal
- Click on "Manage" > "App registrations" and then "New registration"
- Provide a name for the app registration (e.g. mmai-client-appreg)
- Select "Accounts in this organizational directory only" for supported account types
- Provide a redirect URI for "web" in the format **https://<web-app-name>.azurewebsites.net/.auth/login/aad/callback**
- Provide a redirect URI for "Single-page application (SPA)" in the format **https://<web-app-name>.azurewebsites.net/redirect**
  ** Note that there are two ways you can set these redirect URIs
     1) You may set **web-app-name** with **backend_service_name** parameter for terraform, instead of having code to generate a unique name. This way you donn't need to wait for deployment to complete to find out the unique name generated for web app and hence you may set redirect URIs before deploying the solution.
     1) You can also set these redirect URIs after you deployed the solution using **terraform apply** and found out the **web-app-name** ("Manage" > "App registrations" > mmai-client-appreg > "Manage" > "Authentication" >  "Add a platform").
- Select checkbox "ID tokens (used for implicit and hybrid flows)"
- Click "Register" to create the app registration
- Take note of the "Application (client) ID" from the app registration
- After registration is completed navigate to "Manage" > "App registrations" > mmai-client-appreg > "Manage" > "API permissions"
- Click "Add a permission" and select "APIs my organization uses"
- Select **Delegated Permissions**.
- Select the server app registration you created earlier (e.g. **mmai-server-appreg**)
- Select the **access_as_user** permission
- Click "Add permissions" to add the permission
- Navigate to "Manage" > "App registrations" > mmai-client-appreg > "Manage" > "Certificates & secrets"
- Click "New client secret" to create a new secret
- Enter a description (e.g clientapp-secret) and click "Add"
- Take note of the secret value before navigating away from the page, because it will not be shown again


#### App registration for Skills Function App

- Navigate to Microsoft Entra ID in Azure Portal
- Click on "Manage" > "App registrations" and then "New registration"
- Provide a name for the app registration (e.g. mmai-client-appreg)
- Select "Accounts in this organizational directory only" for supported account types
- Take note of the "Application (client) ID" from the app registration

#### Update Deployment Parameters

Finally update the **terraform.tfvars** file with the app registration details you collected in previous steps and run [deployment](#deployment). Note that if you don't want to use secrets in the terraform.tfvars file, you can leave them empty. After terraform deployment is complete you can update the secrets in the keyvault instance created.

```json
webapp_auth_settings = {
  enable_auth           = true
  enable_access_control = true
  server_app = {
    app_id           = "<Server app registration application (client) ID for Web App>"
    app_secret_name  = "<serverapp-secret-name>"
    app_secret_value = "<serverapp-secret-value>"
  }
  client_app = {
    app_id           = "<Client app registration application (client) ID for Web App>"
    app_secret_name  = "<clientapp-secret-name>"
    app_secret_value = "<clientapp-secret-value>"
  }
}

skills_function_appregistration_client_id = "<App registration application (client) ID for Skills Function App>"
```



### Disabling authentication

Disabling authentication for public facing web apps is not recommended. If you need to disable authentication, make sure web application is only accessible through private network. Set  **enable_auth** and **enable_access_control** to false under **webapp_auth_settings** in **terraform.tfvars** file.

```json
webapp_auth_settings = {
  enable_auth           = false
  enable_access_control = false
  server_app = {
    app_id           = ""
    app_secret_name  = ""
    app_secret_value = ""
  }
  client_app = {
    app_id           = ""
    app_secret_name  = ""
    app_secret_value = ""
  }
}
```

## Delete Deployment
- To delete the deployment you need to delete the resource group and app registration. Commands for both are provided in the terraform output variable **cleanup_command**. But if you don't have the output, you can use the following:

  - To delete the resource group using terraform, run the following command:
    ```bash
    terraform destroy
    ```
    or use Azure CLI
    ```bash
    az group delete --name <resource_group_name>
    ```

  - To delete app registration created by this terraform script, run the following command. Note that this command generates commands to delete all app registrations whose name start with "skills". You need to run commands separately from command shell.

    ```powershell
    az ad app list --show-mine | ConvertFrom-Json | Where-Object { $_.displayName -like "mmai-functionapp*" -or $_.displayName -like "mmai-clientapp*" -or $_.displayName -like "mmai-serverapp*" } | select-object -Property @{Name = 'Command'; Expression = {"az ad app delete --id "+$_.appId+" #"+$_.displayName}} | Format-Table -AutoSize
    ```
