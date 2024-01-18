Function Get-DPVhdInfo {
<#
.SYNOPSIS
    Retrieves information about a specified Virtual Hard Disk (VHD).

.DESCRIPTION
    The Get-DPVhdInfo function extracts various details of a VHD file. It uses the 'diskpart.exe' utility to gather 
    information such as the device ID, state, virtual and physical sizes, parent-child relationship, and associated disks.

.PARAMETER Path
    Specifies the path of the VHD file. The function validates that the provided path points to an existing file.

.EXAMPLE
    PS> Get-DPVhdInfo -Path "C:\path\to\file.vhd"
    This example retrieves information about the VHD file located at "C:\path\to\file.vhd".

.INPUTS
    String
    You can input the path of the VHD file as a string to the function.

.OUTPUTS
    PSCustomObject
    The function outputs a custom PowerShell object containing properties like DeviceID, State, VirtualSize, PhysicalSize, 
    IsDiff (indicating if it's a differencing disk), ParentFile, AssociatedDisk, DiskChain, and RootDisk.

.NOTES
    Version:        1.0
    Author:         Holger Voges
    Creation Date:  2024-01-18
#>
    Param(
        [ValidateScript({ if(-not ( Test-Path -Path $_ -PathType leaf )){ Throw 'File does not exist' }; $true })]
        [Parameter(mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [String]$Path 
    )

Begin {    
    $DeviceIDRegEx = '(?:Device type ID|Geträtetyp-ID):\s*(?<DeviceID>\w+)'
    $StateRegEx = '(?:State|Status):\s*(?<State>\w*)'
    $VirtualSizeRegEx = '(?:virtual|virtuelle).*:\s*(?<size>\d*)\s(?<unit>\w+)'
    $PhysicalSizeRegEx = '(?:Physical|Physische).*:\s*(?<size>\d*)\s(?<unit>\w+)'
    $IsChildRegEx = '(?:is Child|ist untergeordnet).*:\s*(?<IsDiff>\w*)'
    $ParentFilenameRegEx = '(?:Parent|Übergeordneter).*?:\s*(?<Parent>\S.*)$'
    $AssociatedDiskRegEx = '(?:associated|Zugeordnete).*:\s*(?<AssocDisk>\w*)$'
}

Process {
    $DiskPartCommand = @'
select vdisk file='{0}'    
Detail Vdisk 
exit
'@ -f $Path
    
    $Data = $DiskPartCommand | diskpart.exe 

    # Remove the Diskpart-Echo-Output
    $StartIndex = [Array]::IndexOf($data,"DISKPART> ",[Array]::IndexOf($data,"DISKPART> ")+1)
    if ( $StartIndex -ne -1 ) {
        $Data = $Data[($StartIndex+1)..($startindex+10)]
    }

    $VDiskInfo = [Ordered]@{
        File = $Path
    }

    Foreach ( $line in $Data ) {
            if ( $line -match $DeviceIDRegEx )       { $VDiskInfo["DeviceID"] = $Matches.DeviceID }
            if ( $line -match $StateRegEx    )       { $VDiskInfo["State"] = $Matches.State }
            if ( $line -match $VirtualSizeRegEx )    { $VDiskInfo["VirtualSize"] = [int]$Matches.size * "1$($Matches.Unit)" }
            if ( $line -match $PhysicalSizeRegEx )   { $VdiskInfo["PhysicalSize"] = [int]$Matches.size * "1$($Matches.Unit)"}
            if ( $line -match $IsChildRegEx )        { $VDiskInfo["IsDiff"] = if ( $Matches.IsDiff -in "Yes","Ja" ) { $true } Elseif ( $Matches.IsDiff -in "Nein","No" ) { $false } }
            if ( $line -match $ParentFilenameRegEx ) { $VDiskInfo["ParentFile"] = $Matches.Parent }
            if ( $line -match $AssociatedDiskRegEx ) { $VDiskInfo["AssociatedDisk"] = $Matches.AssocDisk }
    }
    if ( -not $VDiskInfo.ParentFile ) {
        $VdiskInfo["ParentFile"] = $VdiskInfo.File
        $VdiskInfo["DiskChain"] = $null
        $VdiskInfo["RootDisk"] = $Path
    }
    # Get the Chain of Differencing Disks
    Else {
        $Parent = Get-DPVhdInfo -Path $VDiskInfo.ParentFile
        While ( $Parent.IsDiff ) {
            $DiskChain += @( $Parent.File )
            $Parent = Get-DPVhdInfo -Path $Parent.ParentFile                
        }
        $VdiskInfo["DiskChain"] = $DiskChain + $parent.File
        $VdiskInfo["RootDisk"] = $Parent.File
    }
}

End {
    [PSCustomObject]$VDiskInfo
}
}



