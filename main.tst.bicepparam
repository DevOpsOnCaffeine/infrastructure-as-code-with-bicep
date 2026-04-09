using './main.bicep'

param environment = 'tst'

// Resource Group configuration
param resourceGroupConfig = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for testing
param storageConfig = {
  sku: 'Standard_LRS'
  accessTier: 'Hot'
}


param appServicePlanConfig = {
  skuName: 'S1'
  capacity: 1
}

param appServiceConfig = [
  { 
    index: '001'
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
param networkingConfig = {
  enableVnetIntegration: true
  enableApplicationGateway: false
  vnetAddressSpace: ['10.0.0.0/16']
}
