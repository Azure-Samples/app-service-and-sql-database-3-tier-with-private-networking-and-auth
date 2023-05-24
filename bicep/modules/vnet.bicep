@description('Location for all resources.')
param location string = resourceGroup().location

param virtualNetworkName string

param addressPrefix string = '10.0.0.0/16'

param subnets array = []

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        delegations: ((contains(subnet, 'delegation')) ? [
          {
            name: subnet.name
            properties: {
              serviceName: subnet.delegation
            }
          }] : [])
      }
    }]
  }
}

output virtualNetworkId string = virtualNetwork.id
output virtualNetworkName string = virtualNetwork.name
output subnets array = virtualNetwork.properties.subnets
