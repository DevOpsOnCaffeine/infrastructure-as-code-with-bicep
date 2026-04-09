param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param gatewaySubnetId string
param backendPoolName string = 'app-pool'
param backendAddresses array = []
param enableHttp2 bool = true
param enableWaf bool = false

func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'
func buildNameWithoutHyphens(pre string, type string, env string, reg string, id string) string => '${pre}${type}${env}${reg}${id}'

// Compute names once for reuse
var appGatewayName = buildNameWithHyphens(prefix, 'agw', environment, region, resourceIndex)
var publicIpName = buildNameWithHyphens(prefix, 'pip', environment, region, resourceIndex)

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2024-01-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: gatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPortHttp'
        properties: {
          port: 80
        }
      }
      {
        name: 'appGatewayFrontendPortHttps'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
        properties: {
          backendAddresses: backendAddresses
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'appGatewayProbe')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'appGatewayFrontendPortHttp')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'appGatewayRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, backendPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'appGatewayBackendHttpSettings')
          }
        }
      }
    ]
    probes: [
      {
        name: 'appGatewayProbe'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 10
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
        }
      }
    ]
  }
}

output id string = appGateway.id
output name string = appGateway.name
output publicIpAddress string = publicIp.properties.ipAddress
output frontendIpConfigId string = '${appGateway.id}/frontendIPConfigurations/appGatewayFrontendIP'
