param name string
param location string
param subnetResourceId string
param targetResourceId string
param groupIds array
param privateDnsZoneId string = ''
param tags object = {}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: '${name}-connection'
        properties: {
          privateLinkServiceId: targetResourceId
          groupIds: groupIds
        }
      }
    ]
  }
}

resource privateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = if (!empty(privateDnsZoneId)) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

output id string = privateEndpoint.id
output name string = privateEndpoint.name
