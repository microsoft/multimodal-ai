# Deploying Multimodal AI Platform Using Terraform

There are two ways to deploy the solution:

- [Run deployment from your local machine](./readme_deploy_local.md)
- [Use GitHub Actions](./readme_deploy_gha.md)

## Using the solution

- By default the web application that hosts the **multimodal_ai_web_site** is deployed into a private network. In order to access the web site you will need to do one of the following:
  - Enable public network access for the web app. From Azure portal navigate to Web app > Settings > Networking and click on the line where it reads "Public network access      Disabled". Alternatively, you may use the following CLI command to enable public network access
    ```bash
    az webapp update --resource-group <resource_group_name> --name <webapp_name> --set publicNetworkAccess=Enabled
    ```
  - If you don't want to enable public network access, use a VPN connection to the virtual network where the web app is deployed.

+- Once you have provided the connectivity, navigate to the web site URL provided in the terraform output variable **multimodal_ai_web_site**. Note that if you used a smaller SKU for web app (e.g. B1 or B2), it may take a few minutes for the web app to start. If you see a 504.0 GatewayTimeout error please refresh the web site .

- In order to index and use your own documents for the solution follow instructions provided in section [Indexing Documents](#indexing-documents).

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
