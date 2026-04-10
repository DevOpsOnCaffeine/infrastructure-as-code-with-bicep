param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param applicationType string = 'web'
param workspaceResourceId string

func buildNameWithHyphens(pre string, resType string, env string, reg string, idx string) string => '${pre}-${resType}-${env}-${reg}-${idx}'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: buildNameWithHyphens(prefix, 'appi', environment, region, resourceIndex)
  location: location
  kind: applicationType
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: workspaceResourceId
    IngestionMode: 'LogAnalytics'
  }
}

output id string = applicationInsights.id
output name string = applicationInsights.name
output connectionString string = applicationInsights.properties.ConnectionString
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
