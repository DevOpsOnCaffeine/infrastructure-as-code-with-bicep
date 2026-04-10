using './main.bicep'

param environment = 'tst'

// Resource Group configuration
param resourceGroup = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for testing
param storage = {
  sku: 'Standard_LRS'
  accessTier: 'Hot'
}


param appServicePlan = {
  skuName: 'S1'
  capacity: 1
}

param appService = [
  { 
    index: '001'
    enableVnetIntegration: true
    kind: 'app,linux'
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
  {
    index: '002'
    enableVnetIntegration: true
    kind: 'app,linux'
    siteConfig: {
      linuxFxVersion: 'NODE|20'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
  {
    index: '003'
    enableVnetIntegration: true
    kind: 'app,linux'
    siteConfig: {
      linuxFxVersion: 'PHP|8.2'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
    }
    httpsOnly: true
  }
]

// User-assigned identity configuration for tst
param userAssignedIdentities = [
  {
    index: '001'
    tags: {
      workload: 'app'
      environment: 'tst'
    }
  }
]

// Resource group scoped RBAC assignments for the first user-assigned identity
// Reader role: acdd72a7-3385-48ef-bd42-f606fba81ae7
param roleAssignments = [
  {
    roleDefinitionId: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
    principalType: 'ServicePrincipal'
  }
]

// Key Vault configuration for tst
param keyVault = {
  prefix: 'dummyfin'
  resourceIndex: '001'
  skuName: 'standard'
  enableRbacAuthorization: true
  enablePurgeProtection: true
  softDeleteRetentionInDays: 90
  publicNetworkAccess: 'Enabled'
}

// Key Vault scoped RBAC assignments for the first user-assigned identity
// Key Vault Secrets User role: 4633458b-17de-408a-b874-0445c86b69e6
param keyVaultRoleAssignments = [
  {
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
    principalType: 'ServicePrincipal'
  }
]

// Networking configuration for tst environment
param vnetApp = {
  prefix: 'app'
  resourceIndex: '001'
  enableApplicationGateway: false
  vnetAddressSpace: ['10.1.0.0/16']
  subnets: [
    {
      name: 'app-subnet'
      addressPrefix: '10.1.1.0/24'
      delegations: [
        {
          name: 'serverFarmDelegation'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
        {
          service: 'Microsoft.KeyVault'
        }
      ]
    }
    {
      name: 'appgateway-subnet'
      addressPrefix: '10.1.2.0/24'
      delegations: []
      serviceEndpoints: []
    }
  ]
}

// DB VNet configuration for tst environment - peering disabled
param vnetDb = {
  enableVnetPeering: false
  prefix: 'db'
  resourceIndex: '001'
  vnetAddressSpace: ['10.2.0.0/16']
  subnets: [
    {
      name: 'db-subnet'
      addressPrefix: '10.2.1.0/24'
      delegations: [
        {
          name: 'sqlManagedInstanceDelegation'
          properties: {
            serviceName: 'Microsoft.Sql/managedInstances'
          }
        }
      ]
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
        {
          service: 'Microsoft.KeyVault'
        }
      ]
    }
  ]
}

param vnetAppDbPeering = {
  appToDb: {
    peeringName: 'peer-to-db'
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dbToApp: {
    peeringName: 'peer-to-app'
    allowVirtualNetworkAccess: false
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

param networkSecurity = {
  app: {
    resourceIndex: '001'
    securityRules: []
  }
  gateway: {
    resourceIndex: '001'
    securityRules: []
  }
  db: {
    resourceIndex: '001'
    securityRules: []
  }
}

// Observability baseline configuration for tst environment
param observability = {
  logAnalytics: {
    prefix: 'dummyfin'
    resourceIndex: '001'
    skuName: 'PerGB2018'
    retentionInDays: 30
  }
  appInsights: {
    prefix: 'dummyfin'
    resourceIndex: '001'
    applicationType: 'web'
  }
  diagnostics: {
    appService: {
      enableLogs: true
      enableMetrics: true
    }
  }
}

// Deployment toggles for tst environment
param deploymentToggles = {
  storageAccount: true
  appServicePlan: true
  appServices: true
  vnetApp: true
  vnetDb: true
  applicationGateway: false
  vnetPeering: false
  logAnalytics: true
  appInsights: true
  appServiceDiagnostics: true
  networkSecurityGroups: true
  userAssignedIdentities: true
  roleAssignments: true
  keyVault: true
  keyVaultRoleAssignments: true
}
