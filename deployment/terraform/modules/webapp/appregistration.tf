resource "azuread_application" "server_app" {
  count = var.enable_auth && var.server_app_id == "" ? 1 : 0

  display_name     = local.server_app_display_name
  sign_in_audience = "AzureADMyOrg"

  api {
    requested_access_token_version = 2

    known_client_applications = []

    oauth2_permission_scope {
      admin_consent_description  = "Allows the app to access Azure Search OpenAI Chat API as the signed-in user."
      admin_consent_display_name = "Access Azure Search OpenAI Chat API"
      enabled                    = true
      id                         = local.permission_scope_id
      type                       = "User"
      user_consent_description   = "Allow the app to access Azure Search OpenAI Chat API on your behalf"
      user_consent_display_name  = "Access Azure Search OpenAI Chat API"
      value                      = "access_as_user"
    }
  }

  #identifier_uris = ["api://${var.server_app_display_name}"] set in azuread_application_identifier_uri below

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    # resource_access {
    #   id   = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
    #   type = "Role"
    # }

    # resource_access {
    #   id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.ReadWrite"]
    #   type = "Scope"
    # }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["email"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["offline_access"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"]
      type = "Scope"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["profile"]
      type = "Scope"
    }
  }


  password {
    display_name = local.server_app_secret_name
  }
  owners = [data.azurerm_client_config.current.object_id]

  lifecycle {
    ignore_changes = [
      identifier_uris,
    ]
  }
}

resource "azuread_application_identifier_uri" "server_app_identifier_uri" {
  count          = length(azuread_application.server_app) > 0 ? 1 : 0
  application_id = azuread_application.server_app[0].id #"/applications/${local.server_app_id}"
  identifier_uri = "api://${local.server_app_id}"       #"api://${azuread_application.server_app[0].client_id}"
}

resource "azuread_application" "client_app" {
  count            = var.enable_auth && var.client_app_id == "" ? 1 : 0
  display_name     = local.client_app_display_name
  sign_in_audience = "AzureADMyOrg"

  required_resource_access {
    resource_app_id = azuread_application.server_app[0].client_id

    resource_access {
      id   = local.permission_scope_id
      type = "Scope"
    }
  }
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    # resource_access {
    #   id   = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
    #   type = "Role"
    # }
    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }

  }

  web {
    #set below in azuread_application_redirect_uris resource
    # redirect_uris = ["https://${azurerm_linux_web_app.linux_webapp.default_hostname}/.auth/login/aad/callback"]

    implicit_grant {
      #access_token_issuance_enabled = true
      id_token_issuance_enabled = true
    }
  }

  # set below in azuread_application_redirect_uris resource
  # single_page_application {
  #   redirect_uris = [
  #       "https://${azurerm_linux_web_app.linux_webapp.default_hostname}/redirect",
  #       # "http://localhost:50505/redirect",
  #       # "http://localhost:5173/redirect"
  #   ]
  # }
  password {
    display_name = local.client_app_secret_name
  }
  owners = [data.azurerm_client_config.current.object_id]

  lifecycle {
    ignore_changes = [
      web, single_page_application,
    ]
  }
}



resource "azuread_application_redirect_uris" "client_app_spa" {
  count          = length(azuread_application.client_app) > 0 ? 1 : 0
  application_id = azuread_application.client_app[0].id #"/applications/${local.client_app_id}"
  type           = "SPA"

  redirect_uris = [
    "https://${azurerm_linux_web_app.linux_webapp.default_hostname}/redirect",
  ]
}

resource "azuread_application_redirect_uris" "client_app_web" {
  count          = length(azuread_application.client_app) > 0 ? 1 : 0
  application_id = azuread_application.client_app[0].id #"/applications/${local.client_app_id}"
  type           = "Web"

  redirect_uris = ["https://${azurerm_linux_web_app.linux_webapp.default_hostname}/.auth/login/aad/callback"]
}


resource "azuread_service_principal" "server_app" {
  count     = var.enable_auth && var.server_app_id == "" ? 1 : 0
  client_id = azuread_application.server_app[0].client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "client_app" {
  count     = var.enable_auth && var.client_app_id == "" ? 1 : 0
  client_id = azuread_application.client_app[0].client_id
  owners    = [data.azurerm_client_config.current.object_id]
}


resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}
