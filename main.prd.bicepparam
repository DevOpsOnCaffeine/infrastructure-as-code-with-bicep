using './main.bicep'

param environment = 'prd'

// Resource Group configuration
param resourceGroup = {
  groupType: 'app'
  tags: {}
}

// Storage configuration for production
param storage = {
  sku: 'Premium_GRS'
  accessTier: 'Cool'
}


param appServicePlan = {
  skuName: 'P3'
  capacity: 3
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

// User-assigned identity configuration for prd
param userAssignedIdentities = [
  {
    index: '001'
    tags: {
      workload: 'app'
      environment: 'prd'
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

// Key Vault configuration for prd
param keyVault = {
  prefix: 'dummyfin'
  resourceIndex: '001'
  skuName: 'standard'
  enableRbacAuthorization: true
  enablePurgeProtection: true
  softDeleteRetentionInDays: 90
  publicNetworkAccess: 'Enabled'
  privateEndpoint: {
    resourceIndex: '001'
    subnetName: 'private-endpoints-subnet'
    privateDnsZoneName: 'privatelink.vaultcore.azure.net'
    dnsZoneVnetLinkName: 'keyvault-link-prd-app'
  }
}

// Key Vault scoped RBAC assignments for the first user-assigned identity
// Key Vault Secrets User role: 4633458b-17de-408a-b874-0445c86b69e6
param keyVaultRoleAssignments = [
  {
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'
    principalType: 'ServicePrincipal'
  }
]

// Networking configuration for production - with Application Gateway for HA
param vnetApp = {
  prefix: 'app'
  resourceIndex: '001'
  enableApplicationGateway: true
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
    {
      name: 'private-endpoints-subnet'
      addressPrefix: '10.1.3.0/24'
      delegations: []
      serviceEndpoints: []
    }
  ]
}

// DB VNet configuration for prd environment - peering enabled
param vnetDb = {
  enableVnetPeering: true
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
    securityRules: [
      {
        name: 'Allow-Internet-Http'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-Internet-Https'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'Allow-GatewayManager'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 120
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '65200-65535'
        }
      }
      {
        name: 'Allow-AzureLoadBalancer'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 130
          protocol: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
  db: {
    resourceIndex: '001'
    securityRules: []
  }
}

// Observability baseline configuration for prd environment
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

// Deployment toggles for prd environment
param deploymentToggles = {
  storageAccount: true
  appServicePlan: true
  appServices: true
  vnetApp: true
  vnetDb: true
  applicationGateway: true
  vnetPeering: true
  logAnalytics: true
  appInsights: true
  appServiceDiagnostics: true
  networkSecurityGroups: true
  userAssignedIdentities: true
  roleAssignments: true
  keyVault: true
  keyVaultPrivateEndpoint: true
  keyVaultRoleAssignments: true
}
