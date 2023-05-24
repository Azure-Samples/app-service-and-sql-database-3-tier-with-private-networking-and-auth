param vnetId string

param dnsZoneName string


resource privateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: 'global'
  resource blobStoragePrivateDnsVnetLink 'virtualNetworkLinks' = {
    name: dnsZoneName
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetId
      }
    }
  }
}

output privateDnsId string = privateDns.id
