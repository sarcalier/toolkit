############################################################################################################################
# the script assigns O365 license to users                               
############################################################################################################################

Function Set-O365LicensePack {
    
    param (
        $UPN,
        [ValidateSet(“E1”,”E3”,”F1”)][String]$LicenseName,
        $DisabledLicensePlans
    )

    switch ($LicenseName) {
        "E1" {$SkuId = "18181a46-0d4e-45cd-891e-60aabd171b4e"}
        "E3" {$SkuId = "6fd2c87f-b296-42f0-b197-1e91e994b900"}
        "F1" {$SkuId = "4b585984-651b-448a-9e53-3b10f069cf7f"}
    }
    
    $AzADUser = Get-AzureADUser -ObjectId $UPN
    if (($AzADUser.AssignedLicenses).skuid -eq $SkuId){return $true}
    $SKUs2Remove = (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -like "*pack"}).skuid -notmatch $SkuId
    if ($AzADUser.AssignedLicenses) {$LicPackSKU2Remove = (Compare-Object -ReferenceObject $SKUs2Remove -DifferenceObject ((Get-AzureADUser -ObjectId $UPN).AssignedLicenses).skuid -IncludeEqual | Where-Object {$_.SideIndicator -eq "=="}).InputObject }
    $LicPlanSKUs2Disable =(Get-AzureADSubscribedSku | Where-Object {$_.ObjectId -like "*$SkuId"}).ServicePlans | ForEach-Object {$SP = $_;if ($DisabledLicensePlans | Where-Object {$_ -eq $SP.ServicePlanName}){$SP.ServicePlanId}}
    $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $license.SkuId = $SkuId
    $License.DisabledPlans = $LicPlanSKUs2Disable
    $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $licenses.AddLicenses = $license
    $licenses.RemoveLicenses = $LicPackSKU2Remove
    
    #assign license
    #try {Set-AzureADUserLicense -ObjectId  $UPN -AssignedLicenses $licenses -ErrorAction stop} catch{Set-AzureADUser -ObjectId $Mailbox.ExternalDirectoryObjectId -UsageLocation "FR";Set-AzureADUserLicense -ObjectId  $UPN -AssignedLicenses $licenses}
    Set-AzureADUserLicense -ObjectId  $UPN -AssignedLicenses $licenses -ErrorAction stop
    if ((Get-AzureADUser -ObjectId $UPN).AssignedLicenses.skuid -eq $SkuId){return $true} else{return $false}
}


############################################################################################################################
# prelude                                                     
############################################################################################################################

#$Credential = Get-Credential -UserName FJMessagingGlobalAdmin@kering.onmicrosoft.com -Message GlobalAdmin 
#Connect-AzureAD -Credential $Credential | out-null


############################################################################################################################
# main                                                     
############################################################################################################################



#$colUsers2Fix = Get-Clipboard
$colReport= @()
#$scriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)

$SkuFeaturesToDisable = @("YAMMER_ENTERPRISE")

foreach ($UserUPN in $colUsers2Fix ) {
    try {Get-AzureADUser -ObjectId $UserUPN | Out-Null} 
    catch {
        Write-Host "$UserUPN :UserNotFound" -ForegroundColor Yellow
        $colReport += [PSCustomObject]@{UPN = $UserUPN; Result = "UserNotFound"}
        continue
    }
    if  (Set-O365LicensePack -UPN $UserUPN -LicenseName E3 -DisabledLicensePlans $SkuFeaturesToDisable) {
        Write-Host "$UserUPN :LicenseSetOK" -ForegroundColor Green 
        $colReport += [PSCustomObject]@{UPN = $UserUPN; Result = "LicenseSetOK"}
    }
    else {
        Write-Host "$UserUPN :LicSetFail" -ForegroundColor Red
        $colReport += [PSCustomObject]@{UPN = $UserUPN; Result = "LicSetFail"}
    }

}

#$colReport | Export-Csv -Path $scriptDir\Reports\Assign-O365LicensePack.csv -Delimiter "|" -NoTypeInformation
