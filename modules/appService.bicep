param prefix string
param environment string
param region string
param location string
param appServicePlanId string
param resourceIndex string = '001'
param kind string = 'app,linux'
param site object = {
  linuxFxVersion: 'DOTNETCORE|8.0'
  alwaysOn: true
  http20Enabled: true
  minTlsVersion: '1.2'
  ftpsState: 'Disabled'
}
param httpsOnly bool = true
@description('Optional: Subnet ID for VNET integration')
param vnetIntegrationSubnetId string = ''
@description('Optional: Whether to route all traffic through VNET')
param vnetRouteAllEnabled bool = false
@description('Optional: User-assigned managed identity resource ID to attach to the app service')
param userAssignedIdentityResourceId string = ''
@description('Optional: Application Insights connection string to inject into app settings')
param applicationInsightsConnectionString string = ''
@description('Optional: Log Analytics workspace for App Service diagnostic settings')
param logAnalyticsWorkspaceId string = ''
@description('Optional: App Service diagnostics flags')
param appServiceDiagnostics object = {
  enableLogs: false
  enableMetrics: false
}

func buildNameWithHyphens(pre string, resType string, env string, reg string, id string) string => '${pre}-${resType}-${env}-${reg}-${id}'

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: buildNameWithHyphens(prefix, 'app', environment, region, resourceIndex)
  location: location
  kind: kind
  identity: empty(userAssignedIdentityResourceId) ? {
    type: 'SystemAssigned'
  } : {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityResourceId}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: site
    httpsOnly: httpsOnly
    virtualNetworkSubnetId: !empty(vnetIntegrationSubnetId) ? vnetIntegrationSubnetId : null
  }
}

// Configure VNET integration if subnet ID provided
resource vnetIntegration 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = if (!empty(vnetIntegrationSubnetId)) {
  parent: appService
  name: 'default'
  properties: {
    vnetResourceId: empty(vnetIntegrationSubnetId) ? null : '${split(vnetIntegrationSubnetId, '/subnets/')[0]}'
    isSwift: true
  }
}

// Configure routing preferences for VNET integration
resource appServiceConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: appService
  name: 'web'
  properties: {
    vnetRouteAllEnabled: vnetRouteAllEnabled
  }
}

// Inject app settings only when App Insights is configured for this app.
resource appSettingsConfig 'Microsoft.Web/sites/config@2023-12-01' = if (!empty(applicationInsightsConnectionString)) {
  parent: appService
  name: 'appsettings'
  properties: {
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
  }
}

resource appServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId) && (appServiceDiagnostics.enableLogs || appServiceDiagnostics.enableMetrics)) {
  scope: appService
  name: 'send-to-law'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: appServiceDiagnostics.enableLogs ? [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ] : []
    metrics: appServiceDiagnostics.enableMetrics ? [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ] : []
  }
}

output id string = appService.id
output name string = appService.name
output url string = 'https://${appService.properties.defaultHostName}'
output principalId string = appService.identity.principalId
