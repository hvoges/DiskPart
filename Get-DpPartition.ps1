<#
.SYNOPSIS
Retrieves information about partitions on a disk using Diskpart.

.DESCRIPTION
The Get-DpPartition function retrieves information about partitions on a disk using Diskpart utility. It takes the DiskNumber as a mandatory parameter and returns an object containing the partition number, type, size, and offset.

.PARAMETER DiskNumber
The DiskNumber parameter specifies the disk number for which to retrieve partition information.

.EXAMPLE
Get-DpPartition -DiskNumber 0
Retrieves information about partitions on disk 0.
#>

Function Get-DpPartition {
  [CmdletBinding()]
  param
  (
    [parameter(mandatory = $true,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
    [Alias('ID', 'DiskID')]
    [int]$DiskNumber
  )

  Process {
    [Regex]$RegEx = 'Partition\s(\d)\s*(\w*)\s*(\d*\s\wB)\s*(\d*\s\wB)'


    $DiskpartCommand = @"
Select Disk $DiskNumber
List part
"@   

    $ReturnValue = $DiskpartCommand | diskpart.exe
    foreach ( $line in $ReturnValue ) {
      if ( $line -match $RegEx ) {
        $Partition = [ordered]@{
          Number = $matches[1]
          Type   = $matches[2]
          Size   = $matches[3]
          Offset = $matches[4]
        }
        [PSCustomObject]$Partition
      }
    }
  }
}