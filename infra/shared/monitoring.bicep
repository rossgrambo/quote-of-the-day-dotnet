param logAnalyticsName string
param applicationInsightsName string
param location string = resourceGroup().location
param AItype string
param AIrequestSource string
param LAWsku string
param tags object = {}
param storageAccountResourceId string
param storageAccountRuleName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: LAWsku
    }
  }
}

resource logAnalyticsStorageAccountRule 'microsoft.operationalinsights/workspaces/dataexports@2020-08-01' = {
  parent: logAnalytics
  name: storageAccountRuleName
  properties: {
    destination: {
      resourceId: storageAccountResourceId
    }
    tableNames: [
      'AppEvents'
    ]
    enable: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'other'
  properties: {
    Application_Type: AItype
    Flow_Type: 'Bluefield'
    Request_Source: AIrequestSource
    WorkspaceResourceId: logAnalytics.id
  }
}

output applicationInsightsName string = applicationInsights.name
output logAnalyticsWorkspaceId string = logAnalytics.id
output logAnalyticsWorkspaceName string = logAnalytics.name
