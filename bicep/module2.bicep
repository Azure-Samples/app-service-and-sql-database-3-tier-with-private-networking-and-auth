@description('Location for all resources.')
param location string = resourceGroup().location

@description('Prefix for all resources created by this template')
param prefix string

@secure()
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

//Setup resource names
var planName = '${prefix}-plan'
var apiAppName = '${prefix}-api-app'
var sqlServerName = '${prefix}-sql-server'
var sqlDatabaseName = '${prefix}-db'

//Create the App Service Plan
module planModule './modules/appServicePlan.bicep' = {
  name: planName
  params: {
    location: location
    planName: planName
  }
}

//Create the API App Service
module apiAppModule './modules/appService.bicep' = {
  name: apiAppName
  params: {
    location: location
    appName: apiAppName
    planId: planModule.outputs.planId
    connectionStrings: [{
      connectionString: 'Server=tcp:${sqlServerModule.outputs.serverFullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdministratorLogin};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
      name: 'SampleApiContext'
      type: 'SQLAzure'
    }]
    useAuth: false
    isApi: true
  }
}

//Create the SQL Server
module sqlServerModule './modules/sqlServer.bicep' = {
  name: sqlServerName
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    useAzureAdAuth: false
    usePrivateNetworking: false
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
