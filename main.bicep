targetScope = 'resourceGroup'

// Naming convention variables
param prefix string
param environment string
param region string

param location string = resourceGroup().location

// Storage Account configuration
param storageConfig object

// App Service Plan configuration
param appServicePlanConfig object

// App Service configuration
param appServiceConfig object

// Module references
module storageAccountModule 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: '001'
    storageSku: storageConfig.sku
    accessTier: storageConfig.accessTier
  }
}

module appServicePlanModule 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: '001'
    appServicePlanSkuName: appServicePlanConfig.skuName
    appServicePlanCapacity: appServicePlanConfig.capacity
  }
}

module appServiceModule 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: '001'
    appServicePlanId: appServicePlanModule.outputs.id
    enableAlwaysOn: appServiceConfig.enableAlwaysOn
  }
}

// Outputs
output storageAccountId string = storageAccountModule.outputs.id
output storageAccountName string = storageAccountModule.outputs.name
output storageAccountBlobEndpoint string = storageAccountModule.outputs.primaryBlobEndpoint
output appServicePlanId string = appServicePlanModule.outputs.id
output appServicePlanName string = appServicePlanModule.outputs.name
output appServiceId string = appServiceModule.outputs.id
output appServiceName string = appServiceModule.outputs.name
output appServiceUrl string = appServiceModule.outputs.url
