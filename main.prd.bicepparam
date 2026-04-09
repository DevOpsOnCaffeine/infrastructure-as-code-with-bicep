using './main.bicep'

param prefix = 'dummyfin'
param environment = 'prd'
param region = 'cac'
param location = 'canadacentral'


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
