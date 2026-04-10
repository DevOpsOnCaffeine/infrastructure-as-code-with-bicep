param name string
param location string = 'global'
param virtualNetworkLinks array = []
param tags object = {}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: location
  tags: tags
}

resource privateDnsZoneVirtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = [for link in virtualNetworkLinks: {
  parent: privateDnsZone
  name: link.?name ?? last(split(link.virtualNetworkResourceId, '/'))
  location: link.?location ?? location
  tags: link.?tags ?? {}
  properties: {
    registrationEnabled: link.?registrationEnabled ?? false
    resolutionPolicy: link.?resolutionPolicy ?? 'Default'
    virtualNetwork: {
      id: link.virtualNetworkResourceId
    }
  }
}]

output id string = privateDnsZone.id
output name string = privateDnsZone.name
