param sqlServerName string
param location string = resourceGroup().location
param createNewServer bool = false

param administratorLogin string
@secure()
param administratorLoginPassword string

module newSqlSrv 'sqlSrv-module.bicep' = if (createNewServer) {
  name: sqlServerName
  params: {
    sqlServerName: sqlServerName
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
  }
}

resource sqlSrv 'Microsoft.Sql/servers@2014-04-01' existing = {
  name: newSqlSrv.name
}

param allowedPublicIpAddresses string
param enableAzSvcs bool

module fwRulesModule 'sqlSrv-fwRule-module.bicep' = {
  name: 'fwRules'
  params: {
    allowedPublicIpAddresses: allowedPublicIpAddresses
    sqlServerName: sqlSrv.name
    enableAzSvcs:  enableAzSvcs
  }
}

@allowed([
  'TEST'
  'PROD'
])
@description('target environment')
param environment string

param databaseName string
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

resource db 'Microsoft.Sql/servers/databases@2019-06-01-preview' = {
  name: '${sqlSrv.name}/${databaseName}'
  location: location
  sku: {
    name: environment == 'TEST' ? 'S0' : 'S3'
  }
  properties:{
    collation: collation
  }
}
