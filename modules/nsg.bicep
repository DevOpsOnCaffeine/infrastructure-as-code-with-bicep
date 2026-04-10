param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param securityRules array = []
param tags object = {}

func buildNameWithHyphens(pre string, resType string, env string, reg string, idx string) string => '${pre}-${resType}-${env}-${reg}-${idx}'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-01-01' = {
  name: buildNameWithHyphens(prefix, 'nsg', environment, region, resourceIndex)
  location: location
  tags: tags
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: rule.properties
    }]
  }
}

output id string = networkSecurityGroup.id
output name string = networkSecurityGroup.name
