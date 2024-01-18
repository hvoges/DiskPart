
Function Clear-DpDisk {
  <#
.SYNOPSIS
Removes all Partition-Information from a disk using Diskpart.

.DESCRIPTION
The Clear-DpDisk function is used to clear a disk using Diskpart utility. It selects the specified disk and performs a clean operation.

.PARAMETER Disknumber
The disk number of the disk to be cleared.

.PARAMETER Force
Indicates whether to force the disk clearing operation. If the disk contains a partition, the operation will fail unless this parameter is specified. 

.EXAMPLE
Clear-DpDisk -Disknumber 1
Clears disk number 1 using Diskpart.

.EXAMPLE
Clear-DpDisk -Disknumber 2 -Force
Clears disk number 2 using Diskpart, forcing the operation.

#>
  param
  (
    [Int]
    [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
    [Alias('ID')]
    [Int]$Disknumber,
    
    [switch]$force
  )
  
  Process {
    $DiskpartCommand = @"
Select Disk $Disknumber
Clean
"@

    # $DiskpartCommand | Out-File $env:TEMP\diskpart.txt -Encoding ascii -Force
    $ReturnValue = $DiskpartCommand | diskpart.exe 
    Write-Verbose -Message $ReturnValue[-1]
  }
}