resource "azuread_application" "function_ad_app" {
  display_name = "${var.function_name}-function-adapp"

  required_resource_access {
    # Microsoft Graph App ID
    # az ad sp list --display-name "Microsoft Graph" --query '[].{appDisplayName:appDisplayName, appId:appId}'
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }
  }

  web {
    # We can't use azurerm_function_app.fa.default_hostname because it creates a cycle in Terraform
    redirect_uris = ["https://${var.function_name}.azurewebsites.net/.auth/login/aad/callback"]
    homepage_url  = "https://${var.function_name}.azurewebsites.net"
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}
