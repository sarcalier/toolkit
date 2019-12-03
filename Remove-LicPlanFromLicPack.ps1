<#
#### requires ps-version 3.0 ####
<#
.SYNOPSIS
Disble specific license plan if it is enabled for the Azure AD user
.DESCRIPTION
<Brief description of script>
.PARAMETER <Parameter_Name>
<Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
<Inputs if any, otherwise state None>
.OUTPUTS
<Outputs if anything is generated>
.NOTES
   Version:        0.1
   Author:         Ruslan Gatiyatullin
   Creation Date:  Monday, December 2nd 2019, 11:34:39 am
   File: Remove-LicPlanFromLicPack.ps1
   Copyright (c) 2019 <<company>>
HISTORY:
Date      	          By	Comments
----------	          ---	----------------------------------------------------------

.LINK
   <<website>>

.COMPONENT
 Required Modules: 

.LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the Software), to deal
in the Software without restriction, including without limitation the rights
to use copy, modify, merge, publish, distribute sublicense and /or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
.EXAMPLE
<Example goes here. Repeat this attribute for more than one example>
#
#>
#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#$Credential = Get-Credential -UserName FJMessagingGlobalAdmin@kering.onmicrosoft.com -Message GlobalAdmin 
#Connect-AzureAD -Credential $Credential | out-null

#Set Error Action 
#$ErrorActionPreference = 'SilentlyContinue'
#---------------------------------------------------------[Variables]--------------------------------------------------------
#Log File Info
#$sLogPath = 
#$sLogName = script_name.log
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#---------------------------------------------------------[Functions]--------------------------------------------------------

Function Remove-LicPlanFromUser {
   param (
      $UPN,
      $LicPlans2Disable,
      $LicPacksToSearch,
      $TenantSubSKUs
   )

   #getting Azure Ad user
   $AzADUser = Get-AzureADUser -ObjectId $UPN

   
   #Detect SkuIDs for list of Licens Pack provided
   $TenantLicPackSKUs = ($TenantSubSKUs | Where-Object {$_.SkuPartNumber -in $LicPacksToSearch}).SkuId

   #let`s try to get if user`s got any LicPacks assigned, there is only one license pack to be assigned to user by design
   try { $UserLickPackSKUDetected = (Compare-Object -ReferenceObject $TenantLicPackSKUs -DifferenceObject $AzADUser.AssignedLicenses.SkuId -IncludeEqual -ExcludeDifferent).InputObject } catch {<#$null#>} 
   
   #there is a License Pack matching target ones assigned
   if ($UserLickPackSKUDetected) {
      
      #converting License Plan names 2 disable to SkuIDs
      $LicPlans2DisableSKUs = (($TenantSubSKUs | Where-Object {$_.SkuId -eq "$UserLickPackSKUDetected"}).ServicePlans | Where-Object {$_.ServicePlanName -in $LicPlans2Disable}).ServicePlanId
      
      #detecting if there are License Plans already disabled
      $LicPlansDisabledBefore = ($AzADUser.AssignedLicenses | Where-Object {$UserLickPackSKUDetected -eq $_.SkuId}).DisabledPlans
      if ($LicPlansDisabledBefore) {
         $LicPlans2DisableSKUs +=  $LicPlansDisabledBefore
         $LicPlans2DisableSKUs = $LicPlans2DisableSKUs |Sort-Object -Unique
      }

      #forming the licese object
      $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
      $license.SkuId = $UserLickPackSKUDetected
      $License.DisabledPlans = $LicPlans2DisableSKUs
      $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
      $licenses.AddLicenses = $license

      #final license assignement
      Set-AzureADUserLicense -ObjectId $UPN -AssignedLicenses $licenses -ErrorAction stop
   }
   else {
      Write-Output "No target License Pack assigned"
      return $false
   }
}


#---------------------------------------------------------[Main]--------------------------------------------------------

$TenantSubSKUs = Get-AzureADSubscribedSku
$LicPlans2Disable = @("MYANALYTICS_P2","YAMMER_ENTERPRISE")
$LicPacksToSearch = @("DESKLESSPACK","STANDARDPACK","ENTERPRISEPACK","ENTERPRISEPREMIUM")

Remove-LicPlanFromUser -UPN Ruslan.Gatiyatullin-ext@kering.com -LicPlans2Disable $LicPlans2Disable -TenantSubSKUs $TenantSubSKUs -LicPacksToSearch $LicPacksToSearch


