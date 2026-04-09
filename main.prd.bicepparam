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


param appServiceConfig = {
  enableAlwaysOn: true
}
