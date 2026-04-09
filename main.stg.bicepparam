using './main.bicep'

param environment = 'stg'

// Resource Group configuration
param resourceGroupConfig = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for staging
param storageConfig = {
  sku: 'Standard_GRS'
  accessTier: 'Hot'
}


param appServicePlanConfig = {
  skuName: 'S2'
  capacity: 2
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
