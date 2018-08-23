Connect-AzureRmAccount
Get-AzureRmLocation | ? {$_.DisplayName -like '*East*'}
$rg="lab3"
New-AzureRmResourceGroup -Name $rg -Location eastus 
$job = 'job.' + ((Get-Date).ToUniversalTime()).tostring("MMddyy.HHmm")
$template="C:\Users\rokuehfu\Documents\OneDrivev2\OneDrive\Tech Decks\Azure Stack ARM Hack\lab3\azuredeploy.json"
$parms="C:\Users\rokuehfu\Documents\OneDrivev2\OneDrive\Tech Decks\Azure Stack ARM Hack\lab3\azuredeploy.parameters.json"
$storageAccount = (New-AzureRmResourceGroupDeployment -Name $job -TemplateParameterFile $parms -TemplateFile $template -ResourceGroupName $rg).Outputs.storageAccount.Value
echo "Storage account $storageAccount has been created."

#Step 1: Create Key Vault and set flag to enable for template deployment with ARM
$rgname="lab3"
$rg = Get-AzureRmResourceGroup -Name $rgname
$AsHackName = 'rob'
$asHackVaultName = $AsHackName + 'AsHackVault'
New-AzureRmKeyVault -VaultName $AsHackVaultName -ResourceGroupName $rg.ResourceGroupName -Location $rg.Location -EnabledForTemplateDeployment

#Step 2: Add password as a secret.  Note:this will prompt you for a user and password.  User should be vmadmin and a password that meet the azure pwd police like P@ssw0rd123!!
Set-AzureKeyVaultSecret -VaultName $AsHackVaultName -Name "ubuntuDefaultPassword" -SecretValue (Get-Credential).Password

#Step 3: Update azuredeploy.parameters.json file with your envPrefixName and Key Vault info example- /subscriptions/{guid}/resourceGroups/{group-name}/providers/Microsoft.KeyVault/vaults/{vault-name}
Get-AzureRmKeyVault -VaultName $AsHackVaultName | Select-Object VaultName, ResourceId | fl

#az keyvault secret show --name ubuntuDefaultPassword --vault-name robAsHackVault --query value --output tsv

#Change the parameters file and redeploy
$rgname="lab3"
$rg = Get-AzureRmResourceGroup -Name $rgname
$job = 'job.' + ((Get-Date).ToUniversalTime()).tostring("MMddyy.HHmm")
$template="C:\Users\rokuehfu\Documents\OneDrivev2\OneDrive\Tech Decks\Azure Stack ARM Hack\lab3\azuredeploy.json"
$parms="C:\Users\rokuehfu\Documents\OneDrivev2\OneDrive\Tech Decks\Azure Stack ARM Hack\lab3\azuredeploy.parameters.json"
New-AzureRmResourceGroupDeployment -Name $job -TemplateParameterFile $parms -TemplateFile $template -ResourceGroupName $rg.ResourceGroupName

#az group deployment show --name job.082118.2104 --query properties.outputs.vmRef.value --output json --resource-group lab3