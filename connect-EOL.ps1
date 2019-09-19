function Connect-EOL {
    param (
        #$UserPrincipalName,
        [pscredential]$Credential
    )
    if (((Get-PSSession).State -ne "opened" -and (Get-PSSession).ConfigurationName -eq "Microsoft.Exchange") -or (-not (Get-PSSession))) {
        Get-PSSession | Where-Object {$_.state -eq "Broken"} | Remove-PSSession
        get-module | Where-Object{$_.moduletype -eq "script"} | Remove-Module 
        
        if ($Credential) {
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue 
            Import-PSSession $Session -WarningAction SilentlyContinue -DisableNameChecking | Out-Null
        }    
        if ((Get-PSSession).State -eq "opened" -and (Get-PSSession).ConfigurationName -eq "Microsoft.Exchange") {
            return $true
        }
        else {
            return $false
        }
    }
    else {
        return $true
    }
}