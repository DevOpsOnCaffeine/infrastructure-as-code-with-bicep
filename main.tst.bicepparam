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


param appServiceConfig = {
  enableAlwaysOn: true
}
