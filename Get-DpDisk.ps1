<#
.SYNOPSIS
Retrieves information about disks using Diskpart.

.DESCRIPTION
The Get-DpDisk function uses Diskpart to retrieve information about disks on the system. It parses the output of the "List Disk" command and extracts the disk number, status, size, free space, dynamic status, and GPT status for each disk.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
Get-DpDisk
This example retrieves information about disks using Diskpart and displays the results.

.OUTPUTS
The function outputs a custom object for each disk, containing the following properties:
- DiskNumber: The disk number.
- Status: The status of the disk.
- Size: The size of the disk.
- Free: The amount of free space on the disk.
- Dynamic: Indicates whether the disk is dynamic (True) or not (False).
- GPT: Indicates whether the disk is using GPT (True) or not (False).
#>

Function Get-DpDisk {
  [cmdletBinding()]
  param()

  [Regex]$RegEx = "(?:Disk|Datenträger)\s(\d{1,3})\s{1,}(\w{1,})\s{1,}(\d{1,}\s[KMGTP]{0,1}B)\s{1,}(\d{1,}\s[KMGTP]{0,1}B).{3}(.).{4}(\*| )"
  $ReturnValue = "List Disk" | diskpart.exe 
  
  foreach ( $line in $ReturnValue ) {
    if ( $line -match $RegEx ) {
      [PSCustomObject]@{
        DiskNumber = $matches[1]
        Status     = $matches[2]
        Size       = $matches[3]
        Free       = $matches[4]
        Dynamic    = $( If ( $matches[5] -eq '*' ) { $true } else { $false })
        GPT        = $( If ( $matches[6] -eq '*' ) { $true } else { $false })
      }
    }
  }
}