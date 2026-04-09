param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param appServicePlanSkuName string = 'S1'
param appServicePlanCapacity int = 1

func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'asp', environment, region, resourceIndex)
  location: location
  kind: 'Linux'
  sku: {
    name: appServicePlanSkuName
    tier: appServicePlanSkuName == 'F1' ? 'Free' : appServicePlanSkuName == 'D1' ? 'Shared' : startsWith(appServicePlanSkuName, 'S') ? 'Standard' : startsWith(appServicePlanSkuName, 'P') ? 'Premium' : 'Standard'
    capacity: appServicePlanCapacity
  }
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
