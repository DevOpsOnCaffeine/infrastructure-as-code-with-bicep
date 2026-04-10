param keyVaultName string
param principalId string
@description('Built-in role definition GUID, for example: 4633458b-17de-408a-b874-0445c86b69e6 for Key Vault Secrets User.')
param roleDefinitionId string
@description('Role assignment principal type, defaulting to ServicePrincipal for managed identities.')
param principalType string = 'ServicePrincipal'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, principalId, roleDefinitionId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

output id string = roleAssignment.id
output name string = roleAssignment.name
