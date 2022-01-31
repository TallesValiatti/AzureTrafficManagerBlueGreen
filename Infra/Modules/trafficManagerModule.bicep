@description('Specify the name of the Traffic Manager Profile')
param traficManagerProfileName string

@description('Specify the unique DNS name')
param uniqueDnsName string

@description('Specify endpoint green target resource Id')
param endpointGreentargetResourceId string

@description('Specify endpoint green name')
param endpointGreenName string

@description('Specify endpoint green weight')
param endpointGreenWeight int

@description('Specify endpoint blue target resource Id')
param endpointBluetargetResourceId string

@description('Specify endpoint blue name')
param endpointBlueName string

@description('Specify endpoint blue weight')
param endpointBlueWeight int

resource tmProfile 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: traficManagerProfileName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Weighted'
    dnsConfig: {
      relativeName: uniqueDnsName
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
    }
    endpoints: [
      {
        name: endpointGreenName
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          targetResourceId: endpointGreentargetResourceId
          endpointStatus: 'Enabled'
          weight: endpointGreenWeight
        }
      }
      {
        name: endpointBlueName
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          targetResourceId: endpointBluetargetResourceId
          endpointStatus: 'Enabled'
          weight: endpointBlueWeight
        }
      }
    ]
  }
}
