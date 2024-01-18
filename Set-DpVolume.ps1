<#
.SYNOPSIS
Sets the drive letter or volume number of a disk partition using Diskpart.

.DESCRIPTION
The Set-DpVolume function allows you to set the drive letter or volume number of a disk partition using Diskpart. It supports setting the drive letter by specifying the drive letter or setting the volume number by specifying the volume number. Additionally, it provides an option to mark the partition as active.

.PARAMETER Driveletter
Specifies the drive letter of the partition to be modified. Must be a single letter from C to Z (case-insensitive).

.PARAMETER VolumeNumber
Specifies the volume number of the partition to be modified. Must be an integer.

.PARAMETER ActivePartition
Indicates whether to mark the partition as active.

.EXAMPLE
Set-DpVolume -Driveletter D -ActivePartition
Sets the drive letter of the partition to D and marks it as active.

.EXAMPLE
Set-DpVolume -VolumeNumber 2
Sets the volume number of the partition to 2.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.String. The output of the Diskpart command.

.NOTES
This function requires administrative privileges to run.
#>
Function Set-DpVolume {
  param(   
    [Parameter(mandatory = $true,
      ParameterSetName = 'byDriveLetter')]
    [ValidatePattern('^([C-Zc-z]:?)$')]
    [String]$Driveletter,
    
    [Parameter(Mandatory = $true,
      ParameterSetName = 'byVolumeNumber')]
    [int]$VolumeNumber,
          
    [switch]$ActivePartition  )
  
  If ( $PsCmdlet.ParameterSetName -eq 'byDriveLetter' ) {
    If ( $DriveLetter.Length -eq 2 ) {
      $DriveLetter = $DriveLetter.Substring(0, 1)
    }
    $volume = $DriveLetter
    $AssignLetter = 'Assign Letter = {0}' -f $Driveletter  
  }
  Else {
    $volume = $VolumeNumber
  }
  
  If ( $activePartition ) {
    $Active = 'Active'
  } 

  $DiskpartCommand = @"
Select volume $Volume
$AssignLetter
$Active
"@

  Write-Verbose $DiskpartCommand
  $ReturnValue = $DiskpartCommand | diskpart.exe 
  if ( $ReturnError = $ReturnValue | Select-String -Pattern error -Context 1 ) {
    ( $ReturnError ).Context.PostContext
  }
  Else {
    $ReturnValue[-1]
  }
}