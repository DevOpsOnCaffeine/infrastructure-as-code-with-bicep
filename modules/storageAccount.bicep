param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param storageSku string = 'Standard_LRS'
param accessTier string = 'Hot'

func buildNameWithoutHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}${resType}${env}${reg}${id}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: buildNameWithoutHyphens(prefix, 'st', environment, region, resourceIndex)
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku
  }
  properties: {
    accessTier: accessTier
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

output id string = storageAccount.id
output name string = storageAccount.name
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
