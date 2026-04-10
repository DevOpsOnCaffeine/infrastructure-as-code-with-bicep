param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param tags object = {}

func buildNameWithHyphens(pre string, resType string, env string, reg string, idx string) string => '${pre}-${resType}-${env}-${reg}-${idx}'

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: buildNameWithHyphens(prefix, 'uai', environment, region, resourceIndex)
  location: location
  tags: tags
}

output id string = userAssignedIdentity.id
output name string = userAssignedIdentity.name
output principalId string = userAssignedIdentity.properties.principalId
output clientId string = userAssignedIdentity.properties.clientId
output resourceIndex string = resourceIndex
