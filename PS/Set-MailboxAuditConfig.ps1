<#
#### requires ps-version 3.0 ####
<#
.SYNOPSIS
<Enabling extra mailbox related actions for audit>
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
   Creation Date:  Friday, October 4th 2019, 11:26:58 am
   File: Set-MailboxAuditConfig.ps1
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
#---------------------------------------------------------[Variables]--------------------------------------------------------
#Log File Info
#$sLogPath = 
#$sLogName = script_name.log
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

$i=0
$MbxListFile = "C:\temp\AllMailboxes.txt"

#---------------------------------------------------------[Functions]--------------------------------------------------------

#---------------------------------------------------------[Main]--------------------------------------------------------



 
$MailboxUpnList =  Get-Content -Path $MbxListFile

ForEach ($MailboxUpn in $MailboxUpnList) {
   Write-Progress -activity "Altering Audit Config for $(($MailboxUpnList | Measure-Object).count) mailboxes..." -PercentComplete ($i / ($MailboxUpnList | Measure-Object).count * 100) -status "$(([math]::round((($i / ($MailboxUpnList | Measure-Object).count * 100)))))%";$i++
   Write-Host "         $($MailboxUpn)"
   Set-Mailbox -Identity $MailboxUpn -AuditOwner @{Add="MailboxLogin"} 
   if ($?) {
      Write-Host "=> success"
   }
   else {
      Write-Host "=> fail"
   }
}