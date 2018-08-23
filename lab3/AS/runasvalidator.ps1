#Change powershell resource manager profile to older version for Stack
Update-AzureRmProfile -Profile 2017-03-09-profile -force

#Connect to AS
$AADTenantName = "nttcloudarm.onmicrosoft.com"
$ArmEndpoint = "https://management.dfw.azurestack.nttdacloud.com"

# Register an Azure Resource Manager environment that targets your Azure Stack instance
Add-AzureRMEnvironment `
  -Name "Azure Stack" `
  -ArmEndpoint $ArmEndpoint

$AuthEndpoint = (Get-AzureRmEnvironment -Name "Azure Stack").ActiveDirectoryAuthority.TrimEnd('/')
$TenantId = (invoke-restmethod "$($AuthEndpoint)/$($AADTenantName)/.well-known/openid-configuration").issuer.TrimEnd('/').Split('/')[-1]

# Sign in to your environment
Login-AzureRmAccount `
  -EnvironmentName "Azure Stack" `
  -TenantId $TenantId

#Build a create a cloud capabilities JSON file
Import-Module "C:\AzureStack-Tools-master\CloudCapabilities\AzureRM.CloudCapabilities.psm1"
Get-AzureRMCloudCapability -Location dfw -IncludeComputeCapabilities -IncludeStorageCapabilities -Verbose

#validate templates
Import-Module "C:\AzureStack-Tools-master\TemplateValidator\AzureRM.TemplateValidator.psm1"

Test-AzureRMTemplate -TemplatePath "C:\Users\117212\Documents\GitHub\arm-workshop\lab3\AS\azuredeploy.json" `
    -CapabilitiesPath "C:\Users\117212\Documents\GitHub\arm-workshop\lab3\AS\AzureCloudCapabilities.Json" `
    -IncludeComputeCapabilities `
    -IncludeStorageCapabilities `
    -Verbose `
    -Report "C:\Users\117212\Documents\GitHub\arm-workshop\lab3\AS\lab3TemplateReport.html"
