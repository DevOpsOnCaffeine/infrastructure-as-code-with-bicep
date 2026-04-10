using './main.bicep'

param environment = 'tst'

// Resource Group configuration
param resourceGroup = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for testing
param storage = {
  sku: 'Standard_LRS'
  accessTier: 'Hot'
}


param appServicePlan = {
  skuName: 'S1'
  capacity: 1
}

param appService = [
  { 
    index: '001'
    enableVnetIntegration: true
    kind: 'app,linux'
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
  {
    index: '002'
    enableVnetIntegration: true
    kind: 'app,linux'
    siteConfig: {
      linuxFxVersion: 'NODE|20'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
  {
    index: '003'
    enableVnetIntegration: true
    kind: 'app,linux'
    siteConfig: {
      linuxFxVersion: 'PHP|8.2'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
]

// Networking configuration for tst environment
param vnetApp = {
  prefix: 'app'
  resourceIndex: '001'
  enableApplicationGateway: false
  vnetAddressSpace: ['10.1.0.0/16']
  subnets: [
    {
      name: 'app-subnet'
      addressPrefix: '10.1.1.0/24'
      delegations: [
        {
          name: 'serverFarmDelegation'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
        {
          service: 'Microsoft.KeyVault'
        }
      ]
    }
    {
      name: 'appgateway-subnet'
      addressPrefix: '10.1.2.0/24'
      delegations: []
      serviceEndpoints: []
    }
  ]
}

// DB VNet configuration for tst environment - peering disabled
param vnetDb = {
  enableVnetPeering: false
  prefix: 'db'
  resourceIndex: '001'
  vnetAddressSpace: ['10.2.0.0/16']
  subnets: [
    {
      name: 'db-subnet'
      addressPrefix: '10.2.1.0/24'
      delegations: [
        {
          name: 'sqlManagedInstanceDelegation'
          properties: {
            serviceName: 'Microsoft.Sql/managedInstances'
          }
        }
      ]
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
        {
          service: 'Microsoft.KeyVault'
        }
      ]
    }
  ]
}

param vnetAppDbPeering = {
  appToDb: {
    peeringName: 'peer-to-db'
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dbToApp: {
    peeringName: 'peer-to-app'
    allowVirtualNetworkAccess: false
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// Deployment toggles for tst environment
param deploymentToggles = {
  storageAccount: true
  appServicePlan: true
  appServices: true
  vnetApp: true
  vnetDb: true
  applicationGateway: false
  vnetPeering: false
}
