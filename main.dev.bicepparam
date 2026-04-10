using './main.bicep'

param environment = 'dev'

// Resource Group configuration
param resourceGroup = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for development
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
    enableVnetIntegration: false
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
  // {
  //   index: '002'
  //   enableVnetIntegration: false
  //   kind: 'app,linux'
  //   siteConfig: {
  //     linuxFxVersion: 'NODE|20'
  //     alwaysOn: true
  //     http20Enabled: true
  //     minTlsVersion: '1.2'
  //     ftpsState: 'Disabled'
  //   }
  //   httpsOnly: true
  // }
  // {
  //   index: '003'
  //   enableVnetIntegration: false
  //   kind: 'app,linux'
  //   siteConfig: {
  //     linuxFxVersion: 'PHP|8.2'
  //     alwaysOn: true
  //     http20Enabled: true
  //     minTlsVersion: '1.2'
  //     ftpsState: 'Disabled'
  //   }
  //   httpsOnly: true
  // }
]

// Networking configuration for dev environment
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
// DB VNet configuration for dev environment - peering disabled
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
    allowForwardedTraffic: false
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

param networkSecurity = {
  app: {
    resourceIndex: '001'
    securityRules: []
  }
  gateway: {
    resourceIndex: '001'
    securityRules: []
  }
  db: {
    resourceIndex: '001'
    securityRules: []
  }
}

// Observability baseline configuration for dev environment
param observability = {
  logAnalytics: {
    prefix: 'dummyfin'
    resourceIndex: '001'
    skuName: 'PerGB2018'
    retentionInDays: 30
  }
  appInsights: {
    prefix: 'dummyfin'
    resourceIndex: '001'
    applicationType: 'web'
  }
  diagnostics: {
    appService: {
      enableLogs: true
      enableMetrics: true
    }
  }
}

// Deployment toggles for dev environment
param deploymentToggles = {
  storageAccount: false
  appServicePlan: false
  appServices: false
  vnetApp: true
  vnetDb: true
  applicationGateway: false
  vnetPeering: true
  logAnalytics: true
  appInsights: false
  appServiceDiagnostics: false
  networkSecurityGroups: false
}
