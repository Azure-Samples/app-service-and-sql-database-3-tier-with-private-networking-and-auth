@description('Location for all resources.')
param location string = resourceGroup().location

@description('Prefix for all resources created by this template')
param prefix string

@description('The object ID of the Active Directory administrator user.')
param sqlAdminObjectId string

@description('Has the SQL Server already been created? This is work round a bug in the Bicep SQL Server resource that means it is not idempotent when Azure AD auth is enforced.')
param sqlExists bool = false

@description('The PAT Token used to register agents with Azure DevOps.')
@secure()
param azureDevOpsToken string

@description('The URL of the Azure DevOps instance.')
param azureDevOpsUrl string

@description('The name of the Azure DevOps agent pool.')
param azureDevOpsAgentPool string

@description('The number of build agents to create.')
param agentCount int = 2

@description('The client ID of the API Auth App.')
param apiAuthAppClientId string

@description('The client secret of the API Auth App.')
@secure()
param apiAuthAppSecret string

@description('The client ID of the Web Auth App.')
param webAuthAppClientId string

@description('The client secret of the Web Auth App.')
@secure()
param webAuthAppSecret string

//Setup resource names
var vnetName = '${prefix}-vnet'
var apiAppSubnetName = '${prefix}-api-app-subnet'
var webAppSubnetName = '${prefix}-web-app-subnet'
var privateEndpointSubnetName = '${prefix}-pe-subnet'
var buildAgentSubnetName = '${prefix}-ba-subnet'
var buildAgentName = '${prefix}-build-agent'
var planName = '${prefix}-plan'
var webAppName = '${prefix}-web-app'
var apiAppName = '${prefix}-api-app'
var sqlServerName = '${prefix}-sql-server'
var sqlDatabaseName = '${prefix}-db'
var sqlPrivateEndpointName = '${prefix}-sql-server-private-endpoint'
var apiAppPrivateEndpointName = '${prefix}-api-app-private-endpoint'

//Create virtual network and subnets
module vnetModule './modules/vnet.bicep' = {
  name: vnetName
  params: {
    location: location
    virtualNetworkName: vnetName
    addressPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: apiAppSubnetName
        addressPrefix: '10.0.0.0/24'
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: webAppSubnetName
        addressPrefix: '10.0.1.0/24'
        delegation: 'Microsoft.Web/serverFarms'
      }
      {
        name: privateEndpointSubnetName
        addressPrefix: '10.0.2.0/24'
      }
      {
        name: buildAgentSubnetName
        addressPrefix: '10.0.3.0/24'
        delegation: 'Microsoft.ContainerInstance/containerGroups'
      }
    ]
  }
}

//Get details of the subnets
var apiAppSubnet = filter(vnetModule.outputs.subnets, x => x.name == apiAppSubnetName)[0]
var webAppSubnet = filter(vnetModule.outputs.subnets, x => x.name == webAppSubnetName)[0]
var privateEndpointSubnet = filter(vnetModule.outputs.subnets, x => x.name == privateEndpointSubnetName)[0]
var buildAgentSubnet = filter(vnetModule.outputs.subnets, x => x.name == buildAgentSubnetName)[0]

//Create the Azure DevOps build agents
module buildAgent './modules/containerInstance.bicep' = [for i in range(1,agentCount) : {
  name: '${buildAgentName}-${i}'
  params: {
    name: '${buildAgentName}-${i}'
    agentName: '${buildAgentName}-${i}'
    location: location
    subnetId: buildAgentSubnet.id
    agentAzureDevOpsUrl: azureDevOpsUrl
    agentToken: azureDevOpsToken
    agentPool: azureDevOpsAgentPool
  }
}]

//Create the private dns zone for SQL Server private endpoint
module sqlDnsZone './modules/privateDns.bicep' = {
  name: 'sqlDnsZone'
  params: {
    dnsZoneName:  'privatelink${environment().suffixes.sqlServerHostname}'
    vnetId: vnetModule.outputs.virtualNetworkId 
  }
}

//Create the private dns zone for App Service private endpoint
module appServiceDnsZone './modules/privateDns.bicep' = {
  name: 'appServiceDnsZone'
  params: {
    dnsZoneName:  'privatelink.azurewebsites.net'
    vnetId: vnetModule.outputs.virtualNetworkId 
  }
}

//Create the SQL Server private endpoint
module sqlPrivateEndPoint './modules/privateEndPoint.bicep' = {
  name: sqlPrivateEndpointName
  params: {
    location: location
    dnsZoneId: sqlDnsZone.outputs.privateDnsId
    privateEndpointName: sqlPrivateEndpointName
    subnetId: privateEndpointSubnet.id
    group: 'sqlServer'
    resourceId: sqlServerModule.outputs.serverId
  }
}

//Create the API App Service private endpoint
module apiAppPrivateEndPoint './modules/privateEndPoint.bicep' = {
  name: apiAppPrivateEndpointName
  params: {
    location: location
    dnsZoneId: appServiceDnsZone.outputs.privateDnsId
    privateEndpointName: apiAppPrivateEndpointName
    subnetId: privateEndpointSubnet.id
    group: 'sites'
    resourceId: apiAppModule.outputs.appId
  }
}

//Create the App Service Plan
module planModule './modules/appServicePlan.bicep' = {
  name: planName
  params: {
    location: location
    planName: planName
  }
}

//Create the Web UI App Service
module webAppModule './modules/appService.bicep' = {
  name: webAppName
  params: {
    location: location
    appName: webAppName
    planId: planModule.outputs.planId
    subnetId: webAppSubnet.id
    appSettings: [{
        name: 'ApiUri'
        value: 'https://${apiAppModule.outputs.appUrl}'
      }
      {
        name: 'ApiAuthUri'
        value: 'api://${apiAuthAppClientId}'
      }
    ]
    authClientId: webAuthAppClientId
    authClientSecret: webAuthAppSecret
  }
}

//Create the API App Service
module apiAppModule './modules/appService.bicep' = {
  name: apiAppName
  params: {
    location: location
    appName: apiAppName
    planId: planModule.outputs.planId
    subnetId: apiAppSubnet.id
    connectionStrings: [{
      connectionString: 'Server=tcp:${sqlServerModule.outputs.serverFullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabaseName};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication="Active Directory Default";'
      name: 'SampleApiContext'
      type: 'SQLAzure'
    }]
    authClientId: apiAuthAppClientId
    authClientSecret: apiAuthAppSecret
    isApi: true
  }
}

//Create the SQL Server
module sqlServerModule './modules/sqlServer.bicep' = {
  name: sqlServerName
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlAdminObjectId: sqlAdminObjectId
    alreadyCreated: sqlExists
  }
}

//Create the SQL Database
module databaseModule './modules/sqlDatabase.bicep' = {
  name: sqlDatabaseName
  params: {
    location: location
    sqlServerName: sqlServerModule.outputs.serverName
    databaseName: sqlDatabaseName
  }
}

//Output data used in the pipeline
output serverFullyQualifiedDomainName string = sqlServerModule.outputs.serverFullyQualifiedDomainName
