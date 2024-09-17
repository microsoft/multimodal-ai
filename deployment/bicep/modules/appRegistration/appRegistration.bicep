extension microsoftGraph

@description('Name of the Microsoft Entra ID app')
param clientAppName string

// Create a client application, setting its credential to the X509 cert public key.
resource clientApp 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: clientAppName
  displayName: clientAppName
}

// Create a service principal for the client app
resource clientSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: clientApp.appId
}

output appId string = clientApp.appId
