@description('Location for all resources.')
param location string = resourceGroup().location

param sqlServerName string

param databaseName string

param skuName string = 'Basic'

param capacity int = 5

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' existing = {
  name: sqlServerName
}

resource database 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  parent: sqlServer
  name: databaseName

  location: location
  sku: {
    name: skuName
    tier: skuName
    capacity: capacity
  }
  tags: {
    displayName: databaseName
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'
  }

}
