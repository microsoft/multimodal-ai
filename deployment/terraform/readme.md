# Deploying Multi-model AI Platform Using Terraform

## Requirements

- Terraform v1.6 or later
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)  v2.5 or later
- Azure CLI Extension authV2. Install it by running the following command:
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

- Login to CLI, note that this step is required if you are using Azure Cloud Shell
```bash
az login
```

- Run Terraform command line

```bash
cd deployment/terraform
terraform init
terraform apply
```

- When terraform configuration finishes, it will output the following information:
  - tenant_id : Tenant ID where deployment is done.
  - resource_group_name : The resource group created (default name similar to "rg-mmai-12345678").
  - multimodel_ai_web_site: The web site URL for the Multimodel AI web application.
  - documents_source_storage : Name of the storage account to store documents to be indexed.
  - documents_source_container : Name of the container to store documents to be indexed.
  - skills_function_ad_appregistration_client_id : Application ID of the Azure Function App registration in Azure Active Directory.
  - cleanup_command : Command to delete the resources group and app registration created by the deployment.

## Handling Transient Errors During Deployment

### 504 Gateway Timeout Error

When you deploy compute resources (such as webapp) with minimum capacity, sometimes deployment fails with 504 errors because the the destination server is not responding within the timeout period.

```bash
module.backend_webapp.null_resource.linux_webapp_deployment[0] (local-exec): WARNING: Deployment endpoint responded with status code 504
module.backend_webapp.null_resource.linux_webapp_deployment[0] (local-exec): ERROR: An error occured during deployment. Status Code: 504, Details: 504.0 GatewayTimeout
```

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
- Access the web application using the URL provided in the terraform output variable **multimodel_ai_web_site**.

## Configuring authentication

By default web application is deployed with Azure Active Directory authentication enabled. Deployment configuration also creates client and server app registrations in Azure Entra ID. However, if you don't have privileges to create app registrations, you can either have your Entra ID admin to create app registrations for you or disable authentication.

### Manually creating app registrations

#### Server app registration

- Navigate to Microsoft Entra ID in Azure Portal
- Click on "Manage" > "App registrations" and then "New registration"
- Provide a name for the app registration
- Select "Accounts in this organizational directory only" for supported account types
- Click "Register" to create the app registration
- Take note of the "Application (client) ID" from the app registration
- After registration is completed navigate to "Manage" > "App registrations" > name-of-app-registration > "Manage" > "API permissions"
- Add following delegated permissions for "Microsoft.Graph"
  - email
  - offline_access
  - openid
  - profile
  - User.ReadWrite
- Navigate to "Manage" > "App registrations" > name-of-app-registration > "Manage" > "Expose an API"
- Click "Add a scope" and enter following values
  - Scope name: **access_as_user**
  - Who can consent: **Admins and users**
  - Admin consent display name: **Access Azure Search OpenAI Chat API**
  - Admin consent description: **Allows the app to access Azure Search OpenAI Chat API as the signed-in user.**
  - User consent display name: **Access Azure Search OpenAI Chat API**
  - User consent description: **Allow the app to access Azure Search OpenAI Chat API on your behalf**
  - State: Enabled
  - Click "Add scope" to create the scope
- Navigate to "Manage" > "App registrations" > name-of-app-registration > "Manage" > "Certificates & secrets"
- Click "New client secret" to create a new secret
- Take note of the secret value before navigating away from the page, because it will not be shown again

#### Client app registration

- Navigate to Microsoft Entra ID in Azure Portal
- Click on "Manage" > "App registrations" and then "New registration"
- Provide a name for the app registration
- Select "Accounts in this organizational directory only" for supported account types
- Provide a redirect URI for "web" in the format **https://<web-app-name>.azurewebsites.net/.auth/login/aad/callback**
- Provide a redirect URI for "Single-page application (SPA)" in the format **https://<web-app-name>.azurewebsites.net/redirect**
- Note that you can also set these redirect URIs after you deployed the solution using **terraform apply** ("Manage" > "App registrations" > name-of-app-registration > "Manage" > "Authentication")
- Click "Register" to create the app registration
- Take note of the "Application (client) ID" from the app registration
- After registration is completed navigate to "Manage" > "App registrations" > name-of-app-registration > "Manage" > "API permissions"
- Click "Add a permission" and select "My APIs"
- Select **Delegated Permissions**.
- Select the server app registration (**mmai-serverapp-XXXXXX**) created in previous steps
- Select the **access_as_user** permission
- Click "Add permissions" to add the permission
- Navigate to "Manage" > "App registrations" > name-of-app-registration > "Manage" > "Certificates & secrets"
- Click "New client secret" to create a new secret
- Take note of the secret value before navigating away from the page, because it will not be shown again

#### Update Deployment Parameters

Finally update the **terraform.tfvars** file with the app registration details you collected in previous steps and run [deployment](#deployment). Note that if you don't want to use secrets in the terraform.tfvars file, you can leave them empty. After terraform deployment is complete you can update the secrets in the keyvault instance created.

```json
webapp_auth_settings = {
  enable_auth           = true
  enable_access_control = true
  server_app = {
    app_id           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    app_secret_name  = "<serverapp-secret-name>"
    app_secret_value = "<serverapp-secret-value>"
  }
  client_app = {
    app_id           = "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"
    app_secret_name  = "<clientapp-secret-name>"
    app_secret_value = "<clientapp-secret-value>"
  }
}
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
