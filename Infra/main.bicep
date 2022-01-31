/* 
az deployment sub create --name AzureTrafficManagerBlueGreen --location westus2 --template-file main.bicep

az group delete --name rg-app-prod-eastus2 \ 
&& az group delete --name rg-app-prod-eastus \
&& az group delete --name rg-app-prod-westus2
 */

 // Scope
targetScope = 'subscription'

// Default Location
var defaultLocation = deployment().location

// Shared Variables
var workflowName = 'app'
var workflowEnvironment = 'prod'
var rgDefaultName = 'rg-${workflowName}-${workflowEnvironment}-<REGION>'

var appServicePlanDefaultName = 'appsp-app-${workflowEnvironment}-<REGION>'
var appServiceDefaultName = 'apps-backend-${workflowEnvironment}-<REGION>'
var appServicePlanDefaultSku = 'F1'
var appServiceDefaultRuntime = 'DOTNETCORE|6.0'

// Variables Resource Group eastus2 (Green)
var rgLocationGreen = 'eastus2'
var rgNameGreen = replace(rgDefaultName, '<REGION>', rgLocationGreen)

// Variables Resource Group eastus (Blue)
var rgLocationBlue = 'eastus'
var rgNameBlue = replace(rgDefaultName, '<REGION>', rgLocationBlue)

// Variables Resource Group westus2 (Traffic Manager)
var rgLocationTrafficManager = defaultLocation
var rgNameTrafficManager = replace(rgDefaultName, '<REGION>', rgLocationTrafficManager)

// AppService Green Variables
var appServiceGreenName = replace(appServiceDefaultName, '<REGION>', rgLocationGreen)
var appServiceGreenPlanName = replace(appServicePlanDefaultName, '<REGION>', rgLocationGreen)

// AppService Blue Variables
var appServiceBlueName = replace(appServiceDefaultName, '<REGION>', rgLocationBlue)
var appServiceBluePlanName = replace(appServicePlanDefaultName, '<REGION>', rgLocationBlue)

// Traffic Manager Profile Variables
var traficManagerProfileName = 'tfm-backend-${workflowEnvironment}-${rgLocationTrafficManager}'
var traficManagerUniqueDnsName = 'tfm-backend'
var trafficManagerEndpointGreenName = 'blue-endpoint'
var trafficManagerEndpointBlueName = 'green-endpoint'
var trafficManagerEndpointGreenWeight = 1000
var trafficManagerEndpointBlueWeight = 1

resource rgGreen 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  location: rgLocationGreen
  name: rgNameGreen
}

resource rgBlue 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  location: rgLocationBlue
  name: rgNameBlue
}

resource rgTrafficManager 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  location: rgLocationTrafficManager
  name: rgNameTrafficManager
}

module appServiceGreenModule './Modules/azureWebAppModule.bicep' = {
  name: 'webAppModuleGreen'
  scope: rgGreen
  params: {
    name: appServiceGreenName
    servicePlanName: appServiceGreenPlanName
    sku: appServicePlanDefaultSku
    linuxFxVersion: appServiceDefaultRuntime
  }
}

module appServiceBlueModule './Modules/azureWebAppModule.bicep' = {
  name: 'webAppModuleBlue'
  scope: rgBlue
  params: {
    name: appServiceBlueName
    servicePlanName: appServiceBluePlanName
    sku: appServicePlanDefaultSku
    linuxFxVersion: appServiceDefaultRuntime
  }
}

module trafficManager './Modules/trafficManagerModule.bicep' = {
  name: 'trafficManager'
  scope: rgTrafficManager
  params: {
    traficManagerProfileName: traficManagerProfileName
    uniqueDnsName: traficManagerUniqueDnsName
    endpointGreentargetResourceId: appServiceGreenModule.outputs.appServiceId
    endpointGreenName: trafficManagerEndpointGreenName
    endpointGreenWeight: trafficManagerEndpointGreenWeight
    endpointBluetargetResourceId: appServiceBlueModule.outputs.appServiceId
    endpointBlueName: trafficManagerEndpointBlueName
    endpointBlueWeight: trafficManagerEndpointBlueWeight
  }
}
