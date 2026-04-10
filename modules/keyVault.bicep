param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param skuName string = 'standard'
param enableRbacAuthorization bool = true
@description('Optional: when null, this property is omitted from the request.')
param enablePurgeProtection bool?
param softDeleteRetentionInDays int = 90
param publicNetworkAccess string = 'Enabled'
param tags object = {}

func buildNameWithHyphens(pre string, resType string, env string, reg string, idx string) string => '${pre}-${resType}-${env}-${reg}-${idx}'
var optionalPurgeProtectionProperty = enablePurgeProtection == null ? {} : {
  enablePurgeProtection: enablePurgeProtection
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: buildNameWithHyphens(prefix, 'kv', environment, region, resourceIndex)
  location: location
  tags: tags
  properties: union({
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    enabledForTemplateDeployment: true
    enableRbacAuthorization: enableRbacAuthorization
    softDeleteRetentionInDays: softDeleteRetentionInDays
    publicNetworkAccess: publicNetworkAccess
  }, optionalPurgeProtectionProperty)
}

output id string = keyVault.id
output name string = keyVault.name
output vaultUri string = keyVault.properties.vaultUri
