using './main.bicep'

param prefix = 'dummyfin'
param environment = 'stg'
param region = 'cac'
param location = 'canadacentral'


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
