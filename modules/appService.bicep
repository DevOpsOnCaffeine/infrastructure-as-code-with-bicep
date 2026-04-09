param prefix string
param environment string
param region string
param location string
param appServicePlanId string
param resourceIndex string = '001'
param kind string = 'app,linux'
param siteConfig object = {
  linuxFxVersion: 'DOTNETCORE|8.0'
  alwaysOn: true
  http20Enabled: true
  minTlsVersion: '1.2'
  ftpsState: 'Disabled'
}
param httpsOnly bool = true
@description('Optional: Subnet ID for VNET integration')
param vnetIntegrationSubnetId string = ''
@description('Optional: Whether to route all traffic through VNET')
param vnetRouteAllEnabled bool = false

func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'app', environment, region, resourceIndex)
  location: location
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: siteConfig
    httpsOnly: httpsOnly
    virtualNetworkSubnetId: !empty(vnetIntegrationSubnetId) ? vnetIntegrationSubnetId : null
  }
}

// Configure VNET integration if subnet ID provided
resource vnetIntegration 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = if (!empty(vnetIntegrationSubnetId)) {
  parent: appService
  name: 'default'
  properties: {
    vnetResourceId: empty(vnetIntegrationSubnetId) ? null : '${split(vnetIntegrationSubnetId, '/subnets/')[0]}'
    isSwift: true
  }
}

// Configure routing preferences for VNET integration
resource appServiceConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: appService
  name: 'web'
  properties: {
    vnetRouteAllEnabled: vnetRouteAllEnabled
  }
}

output id string = appService.id
output name string = appService.name
output url string = 'https://${appService.properties.defaultHostName}'
output principalId string = appService.identity.principalId
