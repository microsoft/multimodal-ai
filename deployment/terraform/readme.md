# Deploying Multi-model AI Platform Using Terraform

## Requirements

- Terraform v1.6 or later
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)  v2.5 or later
- Azure CLI Extension authV2. Install it by running the following command:
```bash
az extension add --name authV2
```

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

## Indexing Documents

- Upload documents to the storage account (documents_source_storage) and container (documents_source_container) as provided in the terraform output.
- Navigate to Azure AI Search resource created (default name similar to "srch-12345678")
- Navigate to int indexer created (default name similar to "srch-inder-12345678")
- Click on "Run" to start indexing the documents and wait for process to finish.
- Access the web application using the URL provided in the terraform output variable **multimodel_ai_web_site**.

## Delete Deployment
- To delete the deployment using terraform, run the following command:
```bash
terraform destroy
```
or use Azure CLI to delete the resource group
```bash
az group delete --name <resource_group_name>
```
