#requires -version 2
<#
.SYNOPSIS
  The script connects Exchange Online
.DESCRIPTION
  <Brief description of script>
.PARAMETER
    <Parameter_Name>
        <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         Ruslan Gatiyatullin
  Creation Date:  19.09.2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"

#Dot Source required Function Libraries
#. "C:\Scripts\Functions\Logging_Functions.ps1"

#----------------------------------------------------------[Declarations]----------------------------------------------------------



#Log File Info
#$sLogPath = "C:\Windows\Temp"
#$sLogName = "<script_name>.log"
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

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

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
#Script Execution goes here
#Log-Finish -LogPath $sLogFile

