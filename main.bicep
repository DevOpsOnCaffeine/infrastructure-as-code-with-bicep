// targetScope = 'resourceGroup'

param location string = 'canadacentral'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'dummyfinstdevcac01'
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
