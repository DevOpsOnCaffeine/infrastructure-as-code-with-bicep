targetScope = 'resourceGroup'

// Naming convention variables
param prefix string = 'dummyfin'
param environment string = 'dev'
param region string = 'cac'

param location string = resourceGroup().location

// Module references
module storageAccountModule 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: '001'
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
