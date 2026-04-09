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
    name: 'web001'
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
]
