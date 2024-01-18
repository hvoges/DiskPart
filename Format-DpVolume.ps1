<#
.SYNOPSIS
Formats a volume using Diskpart.

.DESCRIPTION
The Format-DpVolume function formats a volume using Diskpart utility. It supports formatting by drive letter or volume number, and allows specifying the file system, label, and whether to perform a full format.

.PARAMETER DriveLetter
Specifies the drive letter of the volume to be formatted. This parameter is mandatory when using the 'byDriveLetter' parameter set.

.PARAMETER VolumeNumber
Specifies the volume number of the volume to be formatted. This parameter is mandatory when using the 'byVolumeNumber' parameter set.

.PARAMETER FileSystem
Specifies the file system to be used for formatting the volume. Valid values are 'NTFS', 'FAT32', and 'ExFAT'. The default value is 'NTFS'.

.PARAMETER Label
Specifies the label to be assigned to the formatted volume.

.PARAMETER FullFormat
Indicates whether to perform a full format. If this switch is not specified, a quick format will be performed.

.EXAMPLE
Format-DpVolume -DriveLetter 'D' -FileSystem 'NTFS' -Label 'Data' -FullFormat
Formats the volume with drive letter 'D' using NTFS file system, assigns the label 'Data', and performs a full format.

.EXAMPLE
Format-DpVolume -VolumeNumber 2 -FileSystem 'FAT32' -Label 'Backup'
Formats the volume with volume number 2 using FAT32 file system and assigns the label 'Backup'. Performs a quick format by default.

#>
Function Format-DpVolume {
  [cmdletbinding(DefaultParameterSetName = 'byDriveLetter')]
  param(
    [ValidatePattern('^([C-Zc-z]:?)$')]
    [Parameter(Mandatory = $true,
      ParameterSetName = 'byDriveLetter')]
    [string]$DriveLetter,
    
    [Parameter(Mandatory = $true,
      ParameterSetName = 'byVolumeNumber')]
    [int]$VolumeNumber,
    
    [ValidateSet('NTFS', 'FAT32', 'ExFAT')]
    [string]$FileSystem = 'NTFS',
    
    [string]$label,
    
    [Switch]$FullFormat
  )
  
  If ( $PsCmdlet.ParameterSetName -eq 'byDriveLetter' ) {
    If ( $DriveLetter.Length -eq 2 ) {
      $DriveLetter = $DriveLetter.Substring(0, 1)
    }
    $volume = $DriveLetter
  }
  Else {
    $volume = $VolumeNumber
  }
  
  
  $parameter = 'FS={0} Label="{1}"' -f $FileSystem, $label
  If (! $FullFormat ) { $parameter += ' QUICK' }
  Write-Verbose $parameter
  
  $DiskpartCommand = @"
Select Volume=$volume
Format $Parameter
"@
  Write-Verbose $DiskpartCommand

  $ReturnValue = $DiskpartCommand | diskpart.exe
  if ( $ReturnError = $ReturnValue | Select-String -Pattern error -Context 1 ) {
    Write-Error -Message ( $ReturnError ).Context.PostContext
  }
  Else {
    Write-Verbose -Message $ReturnValue[-1]
  }  
}