<#
.SYNOPSIS
Initializes a disk for use with Diskpart.

.DESCRIPTION
The Initialize-DpDisk function initializes a disk for use with Diskpart. It can initialize a disk by disk number, disk type, or through a GUI selection.
It creates a GPT partition table, a 500 MB MSR partition, a 100 MB EFI partition, and a primary partition with the remaining space. It formats the EFI partition with FAT32 and the primary partition with NTFS.

.PARAMETER DiskNumber
Specifies the disk number of the disk to initialize. This parameter is mandatory when using the 'byDiskNumber' parameter set.

.PARAMETER DiskType
Specifies the type of disk to initialize. Valid values are 'HDD', 'SSD', and 'USB'. This parameter is mandatory when using the 'ByDiskType' parameter set.

.PARAMETER ShowDrives
Displays a GUI selection of available drives to choose from. This parameter is mandatory when using the 'byGui' parameter set.

.PARAMETER Force
Forces the initialization of a non-empty disk. Use this parameter to clear the disk anyway.

.EXAMPLE
Initialize-DpDisk -DiskNumber 1
Initializes disk number 1.

.EXAMPLE
Initialize-DpDisk -DiskType 'USB'
Initializes a USB disk.

.EXAMPLE
Initialize-DpDisk -ShowDrives
Displays a GUI selection of available drives and initializes the selected drive.

#>
Function Initialize-DpDisk {
    [cmdletbinding()]
    Param(
        [ValidateScript({ If ( -not ( Get-Disk -Number $_ )) { Throw "The Device is not a USB-Drive or does not exist" }; $true })]
        [Parameter( Mandatory = $true,
            ParameterSetName = 'byDiskNumber' )]
        [int]$DiskNumber,

        [Parameter( Mandatory = $true,
            ParameterSetName = 'ByDiskType')]
        [ValidateSet('HDD', 'SSD', 'USB')]
        $DiskType,

        [Parameter( Mandatory = $true,
            ParameterSetName = 'byGui')]
        [Switch]$ShowDrives,

        [Switch]$force
    )

    If ( $PSBoundParameters.ContainsKey('DiskType')) {
        Switch ( $DiskType ) {
            'USB' { $MediaType = 0 }
            'HDD' { $MediaType = 3 }
            'SSD' { $MediaType = 4 }
        }
        $DiskNumber = Get-CimInstance -Query "select * from MSFT_PhysicalDisk Where MediaType = $mediaType" -Namespace root\Microsoft\Windows\Storage | 
            Sort-Object -Property size -Descending  | 
            Select-Object -first 1 -ExpandProperty DeviceID
    }
    Elseif ( $PSBoundParameters.ContainsKey('ShowDrives')) {
        $Disks = Get-Disk | Select-Object -Property FriendlyName, Size, NumberOfPartitions, PartitionStyle, Number 
        $Disknumber = ( $Disks | Out-GridView -OutputMode Single -Title "Choose a medium" ).Number
    }

    If (-not ( Test-DpDiskEmpty -DiskNumber $DiskNumber ) -and (-not $Force ) ) {
        Write-Error -Message "The Disk is not Empty. Use -force to clear it anyway"
        Return
    }
    else {
        $BootPartition = Get-FreeDriveLetter
        $OSPartition = Get-FreeDriveLetter -Startletter  ([Char]([byte][Char]$BootPartition + 1))
        $VdiskCommandList = @"
Select disk $DiskNumber  
Clean
convert gpt
create part msr size=500
create part efi size=100
format fs=fat32 quick
assign letter=$BootPartition
create part primary
format fs=ntfs label=OsDisk quick
assign letter=$OSPartition
"@
        $ReturnValue = $VdiskCommandList | diskpart.exe
        Write-Verbose -Message $ReturnValue[-1]        
        [PSCustomObject][ordered]@{
            DiskNumber          = $DiskNumber
            BootPartitionLetter = $BootPartition
            OSPartitionLetter   = $OSPartition
        }
    }
}