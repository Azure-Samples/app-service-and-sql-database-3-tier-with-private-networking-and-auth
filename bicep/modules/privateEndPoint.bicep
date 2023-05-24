@description('Location for all resources.')
param location string = resourceGroup().location

param subnetId string

param resourceId string

param dnsZoneId string

param privateEndpointName string

param group string


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location

  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceId
          groupIds: [
            group
          ]
        }
      }
    ]
  }
  resource privateEndpointDnsEntry 'privateDnsZoneGroups' = {
    name: privateEndpointName
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config1'
          properties: {
            privateDnsZoneId: dnsZoneId
          }
        }
      ]
    }
  }
}
