param prefix string
param environment string
param region string
param location string
param appServicePlanId string
param resourceIndex string = '001'
param enableAlwaysOn bool = true

func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'app', environment, region, resourceIndex)
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: enableAlwaysOn
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
}

output id string = appService.id
output name string = appService.name
output url string = 'https://${appService.properties.defaultHostName}'
