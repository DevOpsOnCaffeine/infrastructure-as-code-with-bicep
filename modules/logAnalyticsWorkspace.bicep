param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param skuName string = 'PerGB2018'
param retentionInDays int = 30

func buildNameWithHyphens(pre string, resType string, env string, reg string, idx string) string => '${pre}-${resType}-${env}-${reg}-${idx}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: buildNameWithHyphens(prefix, 'law', environment, region, resourceIndex)
  location: location
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: retentionInDays
    features: {
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
output customerId string = logAnalyticsWorkspace.properties.customerId
