using './main.bicep'

param environment = 'prd'

// Resource Group configuration
param resourceGroupConfig = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for production
param storageConfig = {
  sku: 'Premium_GRS'
  accessTier: 'Cool'
}


param appServicePlanConfig = {
  skuName: 'P3'
  capacity: 3
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

// Networking configuration for production - with Application Gateway for HA
param networkingConfig = {
  enableVnetIntegration: true
  enableApplicationGateway: true
  vnetAddressSpace: ['10.0.0.0/16']
}
