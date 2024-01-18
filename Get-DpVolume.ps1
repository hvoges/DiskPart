<#
.SYNOPSIS
Retrieves information about disk volumes using Diskpart.

.DESCRIPTION
The Get-DpVolume function retrieves information about disk volumes using Diskpart utility. It can retrieve information for a specific disk or for all volumes on the system.

.PARAMETER DiskNumber
Specifies the disk number for which to retrieve volume information. If not specified, information for all volumes will be retrieved.

.EXAMPLE
Get-DpVolume -DiskNumber 1
Retrieves volume information for disk number 1.

.EXAMPLE
Get-DpVolume
Retrieves volume information for all volumes on the system.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Management.Automation.PSCustomObject. The function returns a custom object with the following properties:
- Number: The volume number.
- Driveletter: The assigned drive letter.
- Label: The volume label.
- FileSystem: The file system type.
- Type: The volume type.
- Size: The volume size.
- Status: The volume status.
- BootType: The boot type.

.NOTES
This function requires administrative privileges to run Diskpart utility.
#>
Function Get-DpVolume {
  [CmdletBinding()]
  param
  (
    [parameter(mandatory = $false,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
    [Alias('ID', 'DiskID')]
    [int]$DiskNumber
  )

  Process {
    [Regex]$RegEx = 'Volume\s*(\d+)\s{4,5}([A-Z\s])\s{3}(.+)\s(NTFS|FAT32|FAT|exFAT|ReFS)\s+(\w+)\s+(\d+\s\wB)\s+(\w+)\s{1,2}(.+)$'
    If ( $DiskNumber ) {
      $DiskpartCommand = @"
        Select Disk $DiskNumber
        Det Disk
"@   

    }
    else {
      $DiskpartCommand = @"
  list Volume
"@         
    }

    $ReturnValue = $DiskpartCommand | diskpart.exe
    foreach ( $line in $ReturnValue ) {
      if ( $line -match $RegEx ) {
        $volume = [ordered]@{
          Number      = $matches[1]
          Driveletter = $matches[2]
          Label       = $matches[3]
          FileSystem  = $matches[4]
          Type        = $matches[5]
          Size        = $matches[6]
          Status      = $matches[7]
          BootType    = $matches[8]
        }
        [PSCustomObject]$Volume
      }
    }
  }
}