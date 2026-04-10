param sourceVnetName string
param targetVnetId string
param peeringName string = 'peering-to-target'
param allowForwardedTraffic bool = true
param allowGatewayTransit bool = false
param useRemoteGateways bool = false
param allowVirtualNetworkAccess bool = true

// Create peering from source VNET to target VNET
resource sourceVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-01-01' = {
  name: '${sourceVnetName}/${peeringName}'
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: targetVnetId
    }
  }
}

output peeringId string = sourceVnetPeering.id
output peeringName string = sourceVnetPeering.name
