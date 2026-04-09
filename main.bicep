// targetScope = 'resourceGroup'

// Naming convention variables
param prefix string = 'dummyfin'
param resourceType string = 'st'
param environment string = 'dev'
param region string = 'cac'

// Local functions for naming concatenation
func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'

func buildNameWithoutHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}${resType}${env}${reg}${id}'


param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: buildNameWithoutHyphens(prefix, resourceType, environment, region, '001')
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'asp', environment, region, '001')
  location: location
  kind: 'Linux'
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'app', environment, region, '001')
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
output appServiceId string = appService.id
output appServiceName string = appService.name
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
