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
