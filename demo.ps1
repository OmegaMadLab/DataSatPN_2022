Login-AzAccount

$rgName = "DataSatPN_2022_Demo"

$rg = Get-AzResourceGroup -ResourceGroupName $rgName -ErrorAction SilentlyContinue

if(-not $rg) {
    $rg = New-AzResourceGroup -Name $rgName -Location "Sweden Central"
}

# Deploy the monolithic bicep file
New-AzResourceGroupDeployment -Name "MonolithicDeployment" `
    -ResourceGroupName $rg.ResourceGroupName `
    -TemplateFile ".\BicepFiles\Monolithic\sqlSrvAndDb.bicep" `
    -TemplateParameterFile ".\BicepFiles\Monolithic\sqlSrvAndDb.parameters.json"

# Cleanup
Get-AzResource -ResourceGroupName $rg.ResourceGroupName | Remove-AzResource -force

# Modular approach - local files
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