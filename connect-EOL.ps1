<#
#### requires ps-version 3.0 ####
<#
.SYNOPSIS
<Overview of script>
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
   Creation Date:  Friday, September 20th 2019, 9:46:54 am
   File: Connect-EOL.ps1
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

#Set Error Action 
#$ErrorActionPreference = 'SilentlyContinue'
param (
  [string]$AuthFile,
  [pscredential]$Credential
)

#---------------------------------------------------------[Variables]--------------------------------------------------------
#Log File Info
#$sLogPath = 
#$sLogName = script_name.log
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#---------------------------------------------------------[Functions]--------------------------------------------------------
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
#---------------------------------------------------------[Main]--------------------------------------------------------



if ($AuthFile) {
  $creds = Import-Clixml -Path $AuthFile
  Connect-EOL -Credential $creds
}
elseif ($Credential) {
  Connect-EOL -Credential $Credential
}
else {
  $creds = Get-Credential
  Connect-EOL -Credential $creds
}

