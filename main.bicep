targetScope = 'subscription'

// Directly load the value into the parameter default
param prefix string = loadJsonContent('common-settings.json').prefix
param region string = loadJsonContent('common-settings.json').region
param location string = loadJsonContent('common-settings.json').location

// This works and allows you to still override them in .bicepparam if needed!

param environment string

// Resource Group configuration
param resourceGroupConfig object

// Storage Account configuration
param storageConfig object

// App Service Plan configuration
param appServicePlanConfig object

// App Service configuration
param appServiceConfig object

// Single source of truth for resource group name
func buildNameWithHyphens(prefix string, resType string, env string, reg string, suffix string) string => '${prefix}-${resType}-${env}-${reg}-${suffix}'
var resourceGroupName = buildNameWithHyphens(prefix, 'rg', environment, region, resourceGroupConfig.groupType)
var resourceGroup = az.resourceGroup(resourceGroupName)

// Resource Group Module
module resourceGroupModule 'modules/resourceGroup.bicep' = {
  name: 'resourceGroup'
  params: {
    name: resourceGroupName
    location: location
    tags: resourceGroupConfig.tags
  }
}

// Module references
module storageAccountModule 'modules/storageAccount.bicep' = {
  dependsOn: [resourceGroupModule]
  scope: resourceGroup
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
  dependsOn: [resourceGroupModule]
  scope: resourceGroup
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
  dependsOn: [resourceGroupModule]
  scope: resourceGroup
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
output resourceGroupId string = resourceGroupModule.outputs.id
output resourceGroupName string = resourceGroupModule.outputs.name
output storageAccountId string = storageAccountModule.outputs.id
output storageAccountName string = storageAccountModule.outputs.name
output storageAccountBlobEndpoint string = storageAccountModule.outputs.primaryBlobEndpoint
output appServicePlanId string = appServicePlanModule.outputs.id
output appServicePlanName string = appServicePlanModule.outputs.name
output appServiceId string = appServiceModule.outputs.id
output appServiceName string = appServiceModule.outputs.name
output appServiceUrl string = appServiceModule.outputs.url
