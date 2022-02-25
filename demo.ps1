# Execute environmentPreparation.ps1 to deploy the target environment

$rgName = "DataSatPN_2022_Demo"
$rg = Get-AzResourceGroup -ResourceGroupName $rgName -ErrorAction SilentlyContinue

#region Monolithic approach

# Deploy the monolithic bicep file
New-AzResourceGroupDeployment -Name "MonolithicDeployment" `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\BicepFiles\Monolithic\sqlSrvAndDb.bicep" `
    -TemplateParameterFile ".\BicepFiles\Monolithic\sqlSrvAndDb.parameters.json"

# Cleanup
Get-AzResource -ResourceGroupName $rg.ResourceGroupName | Remove-AzResource -force

#endregion

#region Modular approach

#region with local files
# APP1
New-AzResourceGroupDeployment -Name "Modular-Local-Deployment-APP1" `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\BicepFiles\Modular\APP1-main.bicep" `
    -TemplateParameterFile ".\BicepFiles\Modular\APP1-main.parameters.json"

# APP2
New-AzResourceGroupDeployment -Name "Modular-Local-Deployment-APP2" `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\BicepFiles\Modular\APP2-main.bicep" `
    -TemplateParameterFile ".\BicepFiles\Modular\APP2-main.parameters.json"

# Cleanup
Get-AzResource -ResourceGroupName $rg.ResourceGroupName | Remove-AzResource -force

#endregion

#region with bicep registry

# Push modules to the bicep registry
$registry = Get-AzContainerRegistry -ResourceGroupName "DataSatPN_2022_Demo_BicepResources"

bicep publish ".\BicepFiles\Modular\modules\db-module.bicep" --target "br:$($registry.LoginServer)/modules/db-module:v1"
bicep publish ".\BicepFiles\Modular\modules\sqlSrv-module.bicep" --target "br:$($registry.LoginServer)/modules/sqlsrv-module:v1"
bicep publish ".\BicepFiles\Modular\modules\sqlSrv-fwRule-module.bicep" --target "br:$($registry.LoginServer)/modules/sqlsrv-fwrule-module:v1"

# Define an alias for the registry in bicepConfig.json
[PsCustomObject]$bicepConfig = Get-Content ".\BicepFiles\Modular_BicepRegistry\bicepConfig.json" -Encoding UTF8 | ConvertFrom-Json 
$bicepConfig.moduleAliases.br.DataSatPN.registry = $registry.LoginServer

$bicepConfig

$bicepConfig | ConvertTo-Json -Depth 5 |  Out-File ".\BicepFiles\Modular_BicepRegistry\bicepConfig.json"

# APP1
New-AzResourceGroupDeployment -Name "Modular-Local-Deployment-APP1" `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\BicepFiles\Modular\APP1-main.bicep" `
    -TemplateParameterFile ".\BicepFiles\Modular\APP1-main.parameters.json"

# Cleanup
Get-AzResource -ResourceGroupName $rg.ResourceGroupName | Remove-AzResource -force

#endregion

#endregion