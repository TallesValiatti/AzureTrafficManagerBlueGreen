@description('Specify the name of the Azure App Service')
param name string

@description('Specify the name of the Azure App Service')
param servicePlanName string

@description('Specify the instance size')
param sku string

@description('Specify the programming language stack | Version')
param linuxFxVersion string

@description('Location of all resources')
param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: servicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: name
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}

output appServiceId string = appService.id
