param prefix string
param environment string
param region string
param location string
param appServicePlanId string
param resourceIndex string = '001'
param kind string = 'app,linux'
param siteConfig object = {
  linuxFxVersion: 'DOTNETCORE|8.0'
  alwaysOn: true
  http20Enabled: true
  minTlsVersion: '1.2'
  ftpsState: 'Disabled'
}
param httpsOnly bool = true

func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'app', environment, region, resourceIndex)
  location: location
  kind: kind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: siteConfig
    httpsOnly: httpsOnly
  }
}

output id string = appService.id
output name string = appService.name
output url string = 'https://${appService.properties.defaultHostName}'
