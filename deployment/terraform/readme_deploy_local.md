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

- Contributor role in the target subscription.
- When authenticated with a user principal, you need one of the following application roles: Application.ReadWrite.OwnedBy or Application.ReadWrite.All. Additionally, you may need the User.Read.All application role when including user principals in the owners property. These application roles are also included in Application Administrator or Global Administrator AAD roles.
- When authenticated with a service principal, it needs one of the following application roles: Application.ReadWrite.OwnedBy or Application.ReadWrite.All. Additionally, you may need the User.Read.All application role when including user principals in the owners property.

## Terraform prerequisites deployment (optional)

In case you don't already have a vnet, network security group, route table and private DNS zones already deployed in your subscription, then first navigate to the directory [`/deployment/terraform/prerequisites`](/deployment/terraform/prerequisites). Edit the file called `vars.tfvars` providing your values.

> **Important Note:**
> The default terraform configuration uses remote backend to store terraform state (see `terraform.tf`). You either need to provide corresponding values or you may want to override the backend configuration by creating a `backend_override.tf` file with e.g., following content if you want to manage state locally:
>  ```
>   terraform {
>      backend "local" {
>        path = "./.local-state"
>      }
>   }
>   ```

Next, open the terminal/command line and navigate to the folder [`/deployment/terraform/prerequisites`](/deployment/terraform/prerequisites). Now type the following in the command line:

```sh
terraform init
```

This command will download the necessary Terraform providers and configure the project. Next, type:

```sh
terraform apply -var-file .\vars.tfvars
```

This command will first return a plan describing the changes that will be applied to Azure once confirmed. Before applying the changes to Azure, Terraform will ask for your confirmation.

Type the following into the command line to apply the changes:

```sh
yes
```

Now you will see that Terraform creates a resource group with a virtual network, network security group, route table and will create the **prereqs.tfvars** file under /deployment/terraform/infra folder. "prereqs.tfvars" contains resource IDs to run the terraform deployment, which you will require as part of the next step.

## Deployment

- Next, create a file called `prereqs.tfvars` and paste the following content and replace the placeholders. If you have run prerequisites config, you can skip this step as the `prereqs.tfvars` file will already be created and and populated with all the required parameters.

  ```hcl
  # Logging variables
  log_analytics_workspace_id = "</subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.OperationalInsights/workspaces/<log-analytics-workspace-name>"

  # Network variables
  connectivity_delay_in_seconds = 0
  vnet_id                       = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>"
  nsg_id                        = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/networkSecurityGroups/<nsg-name>"
  route_table_id                = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/routeTables/<route-table-name>"
  subnet_cidr_web               = "10.0.0.0/26"
  subnet_cidr_private_endpoints = "10.0.0.64/26"

  # DNS variables
  private_dns_zone_id_blob               = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  private_dns_zone_id_queue              = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
  private_dns_zone_id_table              = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
  private_dns_zone_id_file               = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
  private_dns_zone_id_vault              = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
  private_dns_zone_id_sites              = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
  private_dns_zone_id_open_ai            = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
  private_dns_zone_id_cognitive_services = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
  private_dns_zone_id_ai_search          = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net"
  private_dns_zone_id_monitor            = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.monitor.azure.com"
  private_dns_zone_id_oms_opsinsights    = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.oms.opinsights.azure.com"
  private_dns_zone_id_ods_opsinsights    = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.ods.opinsights.azure.com"
  private_dns_zone_id_automation         = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/privateDnsZones/privatelink.agentsvc.azure-automation.net"

  ```

- Edit and set mandatory variables in **vars.tfvars** file
  - location
  - environment_name

- You can also change any of the default values provided in **vars.tfvars** file. If a value is not provided for resource names, a value will be created automatically. One special note about **appservice_plan_sku** variable is that if you set this to "B1" or "B2", terraform code will automatically upgrade the SKU to B3 for the duration of code deployment and revert it back when deployment is complete. This is in order to avoid possible 504 Gateway Timeout errors during deployment.

- Login to CLI, note that this step is required if you are using Azure Cloud Shell
  ```bash
  az login
  ```

- Ensure that you are logged on to the correct tenant. Following command should succeed without any errors.
  ```bash
  az account set --subscription <subscription_name_or_id>
  ```

  Next, set the Azure context to define in which subscription you want to deploy the solution. Replace the `<subscription_id>` placeholder with the ID of the subscription you want to use and type the following into your terminal:

  For bash/shell:

  ```sh
  export ARM_SUBSCRIPTION_ID="<subscription_id>"
  az account set --subscription $ARM_SUBSCRIPTION_ID
  ```

  For pwsh:

  ```pwsh
  $env:ARM_SUBSCRIPTION_ID="<subscription_id>"
  az account set --subscription $env:ARM_SUBSCRIPTION_ID
  ```

- Run Terraform command line

  ```bash
  cd deployment/terraform/infra
  ```

> **Important Note:**
> The default terraform configuration uses remote backend to store terraform state (see `terraform.tf`). You either need to provide corresponding values or you may want to override the backend configuration by creating a `backend_override.tf` file with e.g., following content if you want to manage state locally:
>  ```
>   terraform {
>      backend "local" {
>        path = "./.local-state"
>      }
>   }
>   ```

  ```bash
  terraform init
  terraform apply -var-file .\vars.tfvars -var-file .\prereqs.tfvars
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

Run "az login" command and try again. Note that you have to run az login if you are running deployment from Azure Cloud Shell

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
