$colAllOnPremS4BUsers = Import-Csv "C:\Work\Kering\Scripts\Reports\S4Breport4MigrationSRC_190919.csv" -Delimiter "|"
$Credential = Import-Clixml -Path "C:\Work\Kering\Scripts\Creds\FJMessagingGlobalAdmin@kering.onmicrosoft.com.txt"
Connect-AzureAD -Credential $Credential | out-null

$colAllUsers2Report = @()
$i=0

$colAllOnPremS4BUsers | ForEach-Object{
    
    $OnPremS4BUser = $_
    $OriginatorSid = $OnPremS4BUser.OriginatorSid
    $AzADUser = Get-AzureADUser -Filter "OnPremisesSecurityIdentifier eq '$OriginatorSid'"
    
    Write-Progress -Activity "Collecting data for $($colAllOnPremS4BUsers.count) users…" -PercentComplete (($i /$colAllOnPremS4BUsers.count) * 100) -status $i;$i++
    Write-Output "$i $($AzADUser.UserPrincipalName)"

    #$OnPremS4BUser = $_
    #$S4BUserSIP = $OnPremS4BUser.SipAddress
    #$AzADUser = Get-AzureADUser -Filter "SipProxyAddress eq '$S4BUserSIP'"
    
        #Get region
        $RegionGuess = ""
        try {$RegionGuess = (((($AzADUser).extensionproperty.onPremisesDistinguishedName).split(",") | Select-Object -last 3)[0]).split("=")[1]} catch {<#do nothing#>}
        Switch ($RegionGuess) {
            "emea" {$Region = "EMEA"}
            "amer" {$Region = "AMER"}
            "apac" {$Region = "APAC"}
            "PPR Branches" {$Region = "Resource Domain"}
            "Service Accounts" {$Region = "Resource Domain"}
            Default {$Region = "UNKNOWN"}
        }      

        #Cloud or NOT
        Switch ($OnPremS4BUser.HostingProvider) {
            "SRV:" {$S4Bhosting = "OnPrem"}
            "sipfed.online.lync.com" {$S4Bhosting = "Cloud"}
            Default {$S4Bhosting = "UNKNOWN"}
        }

    $UserToReport = [pscustomobject]@{
        DisplayName = $OnPremS4BUser.Displayname
        CloudUPN = $AzADUser.UserPrincipalName
        RegionDomain = $Region
        S4BHosting = $S4Bhosting
        SipAddress = $AzADUser.SipProxyAddress
        Company = $AzADUser.CompanyName
        City = $AzADUser.City
        Country = $AzADUser.Country
        WhenCreated = $AzADUser.extensionproperty.createdDateTime
    }
    $colAllUsers2Report += $UserToReport
}