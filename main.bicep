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

// App Service configuration (array for multiple apps)
param appServiceConfig array = []

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

// Deploy app services in parallel batches for improved performance
// @batchSize(2) controls the number of concurrent module deployments:
//   - Each batch processes up to 2 app services simultaneously
//   - Reduces overall deployment time compared to sequential deployment
//   - For 3 apps: batch 1 deploys app-001 and app-002 in parallel, batch 2 deploys app-003
// Note: All apps in the loop share the same App Service Plan (appServicePlanModule)
// Adjust @batchSize based on resource limits and concurrent deployment capacity
@batchSize(2)
module appServiceModules 'modules/appService.bicep' = [for (appConfig, index) in appServiceConfig: {
  dependsOn: [resourceGroupModule]
  scope: resourceGroup
  name: 'appService-${appConfig.index}'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: appConfig.index
    appServicePlanId: appServicePlanModule.outputs.id
    siteConfig: appConfig.siteConfig
    kind: appConfig.kind
    httpsOnly: appConfig.httpsOnly
  }
}]

// Outputs
output resourceGroupId string = resourceGroupModule.outputs.id
output resourceGroupName string = resourceGroupModule.outputs.name
output storageAccountId string = storageAccountModule.outputs.id
output storageAccountName string = storageAccountModule.outputs.name
output storageAccountBlobEndpoint string = storageAccountModule.outputs.primaryBlobEndpoint
output appServicePlanId string = appServicePlanModule.outputs.id
output appServicePlanName string = appServicePlanModule.outputs.name
output appServiceUrls array = [for i in range(0, length(appServiceConfig)): appServiceModules[i].outputs.url]
