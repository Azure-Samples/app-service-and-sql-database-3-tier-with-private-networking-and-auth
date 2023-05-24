@description('Location for all resources.')
param location string = resourceGroup().location

@description('The Runtime stack of current web app')
param linuxFxVersion string = 'DOTNETCORE|7.0'

@description('The plan id for the app service plan')
param planId string

param appName string

param subnetId string = ''

param appSettings array = []

param connectionStrings array = []

param useAuth bool = true

param authClientId string = ''

@secure()
param authClientSecret string = ''

param isApi bool = false

var clientSecretKey = 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appName
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: planId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      vnetRouteAllEnabled: true
      appSettings: concat(appSettings, [
        {
          name: clientSecretKey
          value: authClientSecret  //TODO: This should be stored in a Key Vault      
        }
      ])
      connectionStrings: connectionStrings
      alwaysOn: true
    }
    virtualNetworkSubnetId: ((!empty(subnetId)) ? subnetId : null)
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource symbolicname 'Microsoft.Web/sites/config@2022-03-01' = if(useAuth) {
  name: 'authsettingsV2'
  parent: webApp
  properties: {
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: authClientId
          clientSecretSettingName: clientSecretKey
          openIdIssuer: 'https://sts.windows.net/${tenant().tenantId}/v2.0'
        }
        validation: {
          allowedAudiences: [
            'api://${authClientId}'
          ]
        }
      }
    }
    globalValidation: {
      redirectToProvider: 'AzureActiveDirectory'
      unauthenticatedClientAction: isApi ? 'Return401' : 'RedirectToLoginPage'
      
    } 
    login: {
      tokenStore: {
        enabled: true
      }
    }
  }
}

output appId string = webApp.id
output appUrl string = webApp.properties.defaultHostName
