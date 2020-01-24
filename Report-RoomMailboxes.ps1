<#
#### requires ps-version 3.0 ####
<#
.SYNOPSIS
<Reports room mailbox properties, Distribution List membership>
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
   Creation Date:  Thursday, January 23rd 2020, 8:23:08 am
   File: Report-RoomMailboxes.ps1
   Copyright (c) 2020 <<company>>
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


#$Credential = Get-Credential
#Connect-EOL -Credential $Credential | out-null


#collecting required DLs and rooms
#$colRoomDLs = Get-DistributionGroup -ResultSize unlimited -Filter {RecipientTypeDetails -eq "RoomList"}
#$colRoomMbxs = Get-Mailbox -Filter {RecipientTypeDetails -eq "RoomMailbox"} -ResultSize unlimited
$i = 0
$AllReport = @()

foreach ($room in $colRoomMbxs) {
    Write-Output "$i $($room.identity)"
    $RoomDLmatch = @()
    foreach ($DL in $colRoomDLs) {
        $DLMemberIDs = (Get-DistributionGroupMember -Identity $DL.Identity).ExchangeGuid.guid
        #coCheck for empty DL
        if (!($DLMemberIDs)) {continue}
        if (Compare-Object -ReferenceObject $room.exchangeguid.guid -DifferenceObject $DLMemberIDs -IncludeEqual -ExcludeDifferent) {
            #Write-Host "$($room.DisplayName) $($DL.DisplayName)"
            $RoomDLmatch += $DL.DisplayName
        }   
    }
    
    #calendar info
    $roomCP = Get-CalendarProcessing -Identity $room.ExchangeGuid.Guid
    
    #SendAs users
    $roomSAs = (Get-RecipientPermission -Identity $room.ExchangeGuid.guid | Where-Object{($_.Trustee -ne "NT AUTHORITY\SELF") -and ($_.Trustee -notlike "S-1-5-21-*") -and ($_.Trustee -ne $room.UserPrincipalName) -and (!($_.Trustee.contains("\")))}).trustee

    #FullAccess
    $roomFAs = (Get-MailboxPermission -Identity $room.ExchangeGuid.guid | Where-Object{($_.IsInherited -ne $True) -and ($_.user -ne "NT AUTHORITY\SELF") -and ($_.user -ne $room.UserPrincipalName) -and ($_.User -notlike "S-1-5-21-*") -and (!($_.User.contains("\"))) -and ($_.AccessRights -like "*FullAccess*")}).user

    $RoomReport = [pscustomobject]@{
        Identity = $room.Identity
        ResourceCapacity = $room.ResourceCapacity
        ResourceType = $room.ResourceType
        Office = $room.Office
        UserPrincipalName = $room.UserPrincipalName
        UsageLocation = $room.UsageLocation
        IsDirSynced = $room.IsDirSynced
        DisplayName = $room.DisplayName
        GrantSendOnBehalfTo = $room.GrantSendOnBehalfTo
        ExchangeGuid = $room.ExchangeGuid.Guid
        PrimarySmtpAddress = $room.PrimarySmtpAddress
        RoomList = $RoomDLmatch
        AutomateProcessing = $roomCP.AutomateProcessing
        ResourceDelegates = $roomCP.ResourceDelegates
        AllowRecurringMeetings = $roomCP.AllowRecurringMeetings
        ScheduleOnlyDuringWorkHours = $roomCP.ScheduleOnlyDuringWorkHours
        MaximumDurationInMinutes = $roomCP.MaximumDurationInMinutes
        SendAs = $roomSAs
        FullAccess = $roomFAs
    }  
 
    #$RoomReport
    $AllReport += $RoomReport
    $i++

    #$RoomReport
}

$AllReport | Select-Object Identity,ResourceCapacity,ResourceType,Office,UserPrincipalName,UsageLocation,IsDirSynced,DisplayName,GrantSendOnBehalfTo,ExchangeGuid,PrimarySmtpAddress,@{Name='RoomList';Expression={($_.RoomList) -join ","}},AutomateProcessing,ResourceDelegates,AllowRecurringMeetings,ScheduleOnlyDuringWorkHours,MaximumDurationInMinutes,@{Name='SendAs';Expression={($_.SendAs) -join ","}},@{Name='FullAccess';Expression={($_.FullAccess) -join ","}} | Export-Csv -Path "C:\Work\Kering\Scripts\Reports\Report-RoomMailboxes.csv" -Delimiter "|" -NoTypeInformation


