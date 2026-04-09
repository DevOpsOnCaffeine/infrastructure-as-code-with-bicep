param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'

func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'asp', environment, region, resourceIndex)
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

output id string = appServicePlan.id
output name string = appServicePlan.name
