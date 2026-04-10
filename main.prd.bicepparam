using './main.bicep'

param environment = 'prd'

// Resource Group configuration
param resourceGroup = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for production
param storage = {
  sku: 'Premium_GRS'
  accessTier: 'Cool'
}


param appServicePlan = {
  skuName: 'P3'
  capacity: 3
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

// Networking configuration for production - with Application Gateway for HA
param vnetApp = {
  prefix: 'app'
  resourceIndex: '001'
  enableApplicationGateway: true
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

// DB VNet configuration for prd environment - peering enabled
param vnetDb = {
  enableVnetPeering: true
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

// Deployment toggles for prd environment
param deploymentToggles = {
  storageAccount: true
  appServicePlan: true
  appServices: true
  vnetApp: true
  vnetDb: true
  applicationGateway: true
  vnetPeering: true
}
