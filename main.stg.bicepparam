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


param appServiceConfig = {
  enableAlwaysOn: true
}
