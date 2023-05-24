@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the SQL logical server.')
param sqlServerName string

@description('The administrator username of the SQL logical server')
param sqlAdministratorLogin string = ''

@description('The administrator password of the SQL logical server.')
@secure()
param sqlAdministratorLoginPassword string = ''

@description('The object ID of the Active Directory administrator user.')
param sqlAdminObjectId string = ''

param useAzureAdAuth bool = true

param usePrivateNetworking bool = true

@description('Has the SQL Server already been created? This is work round a bug in the Bicep SQL Server resource that means it is not idempotent when Azure AD auth is enforced.')
param alreadyCreated bool = false //When a SQL Server is being created a username and password must be supplied even if SQL Auth is being turned off. If SQL Auth is off, the deployment fails if you try to supply a username and password in an update... :(

resource sqlServerManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if(useAzureAdAuth) {
  name: sqlServerName
}

resource sqlServer 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name: sqlServerName
  location: location

  identity: useAzureAdAuth ? {
    type: 'UserAssigned'
    userAssignedIdentities: { 
      '${sqlServerManagedIdentity.id}': {} 
    }
  } : null

  properties: {
    administratorLogin: ((!empty(sqlAdministratorLogin)) ? sqlAdministratorLogin : (alreadyCreated ? null :'temptest')) 
    administratorLoginPassword: ((!empty(sqlAdministratorLoginPassword)) ? sqlAdministratorLoginPassword : (alreadyCreated ? null :'A1b!@dsfs9ds98dfdfhhfjj@@'))
    version: '12.0'
    publicNetworkAccess: usePrivateNetworking ? 'Disabled' : 'Enabled' //Turn this on to enable external access
    primaryUserAssignedIdentityId: useAzureAdAuth ? sqlServerManagedIdentity.id : null
    administrators: useAzureAdAuth ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      principalType: 'Application'
      login: 'admin_user_service_principal'
      sid: sqlAdminObjectId
      tenantId: tenant().tenantId
    } : null
  }
}

/*
resource sqlServerAadAdmin 'Microsoft.Sql/servers/administrators@2021-11-01' = if(useAzureAdAuth) {
  name: 'ActiveDirectory' //NOTE: Must be called 'ActiveDirectory' or it won't work!
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'admin_user_service_principal'
    sid: sqlAdminObjectId
    tenantId: tenant().tenantId
  }
}

//Remove this to enable SQL Accounts
resource sqlServerAzureAdOnly 'Microsoft.Sql/servers/azureADOnlyAuthentications@2021-11-01' = if(useAzureAdAuth) {
  name: 'Default'
  parent: sqlServer
  properties: {
    azureADOnlyAuthentication: true
  }
  dependsOn: [
    sqlServerAadAdmin
  ]
}
*/

// Allow Azure services to access the server. Needed for early stages of development.
resource sqlServerFirewallRules 'Microsoft.Sql/servers/firewallRules@2021-11-01' = if(!usePrivateNetworking) {
  name: 'sqlServerFirewallRules'
  parent: sqlServer
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
output serverId string = sqlServer.id
output serverName string = sqlServer.name
