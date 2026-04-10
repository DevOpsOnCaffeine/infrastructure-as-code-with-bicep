targetScope = 'subscription'

// Directly load the value into the parameter default
param prefix string = loadJsonContent('common-settings.json').prefix
param region string = loadJsonContent('common-settings.json').region
param location string = loadJsonContent('common-settings.json').location

// This works and allows you to still override them in .bicepparam if needed!

param environment string

// Resource Group configuration
param resourceGroup object

// Storage Account configuration
param storage object

// App Service Plan configuration
param appServicePlan object

// App Service configuration (array for multiple apps)
param appService array = []

// Networking configuration
param vnetApp object

// Secondary Virtual Network configuration for database tier
param vnetDb object = {
  enableVnetPeering: false
  prefix: 'db'
  resourceIndex: '001'
  vnetAddressSpace: ['10.2.0.0/16']
  subnets: [
    {
      name: 'db-subnet'
      addressPrefix: '10.2.1.0/24'
      delegations: [
        {
          name: 'sqlManagedInstanceDelegation'
          properties: {
            serviceName: 'Microsoft.Sql/managedInstances'
          }
        }
      ]
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
        {
          service: 'Microsoft.KeyVault'
        }
      ]
    }
  ]
}

// VNET peering configuration
param vnetAppDbPeering object = {
  appToDb: {
    peeringName: 'peer-to-db'
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dbToApp: {
    peeringName: 'peer-to-app'
    allowVirtualNetworkAccess: false
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

// Resource deployment toggles
// Set any flag to false to exclude that resource from the deployment
param deploymentToggles object = {
  storageAccount: true
  appServicePlan: true
  appServices: true
  vnetApp: true
  applicationGateway: false
  vnetDb: true
  vnetPeering: false
}

// Single source of truth for resource group name
func buildNameWithHyphens(prefix string, resType string, env string, reg string, suffix string) string => '${prefix}-${resType}-${env}-${reg}-${suffix}'
var resGroupName = buildNameWithHyphens(prefix, 'rg', environment, region, resourceGroup.groupType)
var resGroupRef = az.resourceGroup(resGroupName)

// Resource Group Module
module resourceGroupModule 'modules/resourceGroup.bicep' = {
  name: 'resourceGroup'
  params: {
    name: resGroupName
    location: location
    tags: resourceGroup.tags
  }
}

module storageAccountModule 'modules/storageAccount.bicep' = if (deploymentToggles.storageAccount) {
  dependsOn: [resourceGroupModule]
  scope: resGroupRef
  name: 'storageAccount'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: '001'
    storageSku: storage.sku
    accessTier: storage.accessTier
  }
}

module appServicePlanModule 'modules/appServicePlan.bicep' = if (deploymentToggles.appServicePlan) {
  dependsOn: [resourceGroupModule]
  scope: resGroupRef
  name: 'appServicePlan'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: '001'
    appServicePlanSkuName: appServicePlan.skuName
    appServicePlanCapacity: appServicePlan.capacity
  }
}

// Virtual Network Module
module vnetAppModule 'modules/vnet.bicep' = if (deploymentToggles.vnetApp) {
  dependsOn: [resourceGroupModule]
  scope: resGroupRef
  name: 'vnet-app'
  params: {
    prefix: vnetApp.prefix
    environment: environment
    region: region
    location: location
    resourceIndex: vnetApp.resourceIndex
    addressSpace: vnetApp.vnetAddressSpace
    subnets: vnetApp.subnets
  }
}

// Application Gateway Module
module appGatewayModule 'modules/applicationGateway.bicep' = if (deploymentToggles.applicationGateway) {
  dependsOn: [resourceGroupModule]
  scope: resGroupRef
  name: 'applicationGateway'
  params: {
    prefix: 'app'
    environment: environment
    region: region
    location: location
    resourceIndex: '001'
    gatewaySubnetId: vnetAppModule!.outputs.subnets[1].id
    backendPoolName: 'app-backend-pool'
    backendAddresses: [for appConfig in appService: {
      fqdn: '${prefix}-app-${environment}-${region}-${appConfig.index}.azurewebsites.net'
    }]
  }
}

// Secondary Virtual Network Module for database tier
module vnetDbModule 'modules/vnet.bicep' = if (deploymentToggles.vnetDb) {
  dependsOn: [resourceGroupModule]
  scope: resGroupRef
  name: 'vnet-db'
  params: {
    prefix: vnetDb.prefix
    environment: environment
    region: region
    location: location
    resourceIndex: vnetDb.resourceIndex
    addressSpace: vnetDb.vnetAddressSpace
    subnets: vnetDb.subnets
  }
}

// VNET Peering from app tier to database tier
module vnetPeeringAppToDb 'modules/vnetPeering.bicep' = if (deploymentToggles.vnetPeering) {
  scope: resGroupRef
  name: 'peering-app-to-db'
  params: {
    sourceVnetId: vnetAppModule!.outputs.id
    sourceVnetName: vnetAppModule!.outputs.name
    sourceResourceGroupName: resGroupName
    targetVnetId: vnetDbModule!.outputs.id
    targetVnetName: vnetDbModule!.outputs.name
    peeringName: vnetAppDbPeering.appToDb.peeringName
    allowVirtualNetworkAccess: vnetAppDbPeering.appToDb.allowVirtualNetworkAccess
    allowForwardedTraffic: vnetAppDbPeering.appToDb.allowForwardedTraffic
    allowGatewayTransit: vnetAppDbPeering.appToDb.allowGatewayTransit
    useRemoteGateways: vnetAppDbPeering.appToDb.useRemoteGateways
  }
}

// Reverse peering from database tier back to app tier
// Required to bring both sides to Connected state, but allowVirtualNetworkAccess is false
// so db-vnet resources cannot initiate traffic into app-vnet
module vnetPeeringDbToApp 'modules/vnetPeering.bicep' = if (deploymentToggles.vnetPeering) {
  scope: resGroupRef
  name: 'peering-db-to-app'
  params: {
    sourceVnetId: vnetDbModule!.outputs.id
    sourceVnetName: vnetDbModule!.outputs.name
    sourceResourceGroupName: resGroupName
    targetVnetId: vnetAppModule!.outputs.id
    targetVnetName: vnetAppModule!.outputs.name
    peeringName: vnetAppDbPeering.dbToApp.peeringName
    allowVirtualNetworkAccess: vnetAppDbPeering.dbToApp.allowVirtualNetworkAccess
    allowForwardedTraffic: vnetAppDbPeering.dbToApp.allowForwardedTraffic
    allowGatewayTransit: vnetAppDbPeering.dbToApp.allowGatewayTransit
    useRemoteGateways: vnetAppDbPeering.dbToApp.useRemoteGateways
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
module appServiceModules 'modules/appService.bicep' = [for appConfig in (deploymentToggles.appServices ? appService : []): {
  dependsOn: [resourceGroupModule]
  scope: resGroupRef
  name: 'appService-${appConfig.index}'
  params: {
    prefix: prefix
    environment: environment
    region: region
    location: location
    resourceIndex: appConfig.index
    appServicePlanId: appServicePlanModule!.outputs.id
    site: appConfig.siteConfig
    kind: appConfig.kind
    httpsOnly: appConfig.httpsOnly
    vnetIntegrationSubnetId: appConfig.enableVnetIntegration ? vnetAppModule!.outputs.subnets[0].id : ''
    vnetRouteAllEnabled: appConfig.enableVnetIntegration
  }
}]

// Outputs
output resourceGroupId string = resourceGroupModule!.outputs.id
output resGroupName string = resourceGroupModule!.outputs.name
output storageAccountId string = deploymentToggles.storageAccount ? storageAccountModule!.outputs.id : ''
output storageAccountName string = deploymentToggles.storageAccount ? storageAccountModule!.outputs.name : ''
output storageAccountBlobEndpoint string = deploymentToggles.storageAccount ? storageAccountModule!.outputs.primaryBlobEndpoint : ''
output appServicePlanId string = deploymentToggles.appServicePlan ? appServicePlanModule!.outputs.id : ''
output appServicePlanName string = deploymentToggles.appServicePlan ? appServicePlanModule!.outputs.name : ''
output appServiceUrls array = [for i in range(0, length(deploymentToggles.appServices ? appService : [])): appServiceModules[i].outputs.url]
output vnetId string = deploymentToggles.vnetApp ? vnetAppModule!.outputs.id : ''
output vnetName string = deploymentToggles.vnetApp ? vnetAppModule!.outputs.name : ''
output appGatewayId string = deploymentToggles.applicationGateway ? appGatewayModule!.outputs.id : ''
output appGatewayPublicIp string = deploymentToggles.applicationGateway ? appGatewayModule!.outputs.publicIpAddress : ''
output vnetSecondaryId string = deploymentToggles.vnetDb ? vnetDbModule!.outputs.id : ''
output vnetSecondaryName string = deploymentToggles.vnetDb ? vnetDbModule!.outputs.name : ''
output vnetPeeringAppToDbId string = deploymentToggles.vnetPeering ? vnetPeeringAppToDb!.outputs.peeringId : ''
output vnetPeeringDbToAppId string = deploymentToggles.vnetPeering ? vnetPeeringDbToApp!.outputs.peeringId : ''
