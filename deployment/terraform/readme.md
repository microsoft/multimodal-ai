# Deploying Multi-model AI Platform Using Terraform 

## Requirements

- Terraform v1.6 or later
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)  v2.5 or later



## Deployment

- Set mandatory variables in terraform.tfvars
  - subscription_id
  - location
  - environment_name


- Run Terraform command line

```bash
/multimodel-ai/deployment/terraform> terraform init
/multimodel-ai/deployment/terraform> terraform apply
```
