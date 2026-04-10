param prefix string
param environment string
param region string
param location string
param resourceIndex string = '001'
param addressSpace array = ['10.0.0.0/16']
param subnets array = [
  {
    name: 'app-subnet'
    addressPrefix: '10.0.1.0/24'
    delegations: [
      {
        name: 'serverFarmDelegation'
        serviceName: 'Microsoft.Web/serverFarms'
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

func buildNameWithHyphens(pre string, resType string, env string, reg string, idx string) string => '${pre}-${resType}-${env}-${reg}-${idx}'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: buildNameWithHyphens(prefix, 'vnet', environment, region, resourceIndex)
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpace
    }
    subnets: [for (subnet, index) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        delegations: subnet.delegations
        serviceEndpoints: subnet.serviceEndpoints
        privateLinkServiceNetworkPolicies: 'Disabled'
        privateEndpointNetworkPolicies: 'Disabled'
      }
    }]
  }
}

output id string = vnet.id
output name string = vnet.name
output subnets array = [for subnet in subnets: {
  name: subnet.name
  id: '${vnet.id}/subnets/${subnet.name}'
}]
