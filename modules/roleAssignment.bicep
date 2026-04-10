param principalId string
@description('Built-in role definition GUID, for example: acdd72a7-3385-48ef-bd42-f606fba81ae7 for Reader.')
param roleDefinitionId string
@description('Role assignment principal type, defaulting to ServicePrincipal for managed identities.')
param principalType string = 'ServicePrincipal'
@description('Seed value for deterministic role assignment name generation (for example, resource group ID or Key Vault ID).')
param roleAssignmentNameSeed string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(roleAssignmentNameSeed, principalId, roleDefinitionId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

output id string = roleAssignment.id
output name string = roleAssignment.name
