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



output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
