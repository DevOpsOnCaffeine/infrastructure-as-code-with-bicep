using './main.bicep'

param prefix = 'dummyfin'
param environment = 'dev'
param region = 'cac'
param location = 'canadacentral'


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
