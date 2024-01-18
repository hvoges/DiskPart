<#
.SYNOPSIS
Converts a disk to the specified disk type using Diskpart.

.DESCRIPTION
The Convert-DpDisk function converts a disk to the specified disk type using Diskpart utility. It takes the DiskNumber and DiskType as parameters.

.PARAMETER DiskNumber
The disk number of the disk to be converted.

.PARAMETER DiskType
The type of disk to convert to. Valid values are 'GPT', 'MBR', 'Dynamic', and 'Basic'. The default value is 'GPT'.

.EXAMPLE
Convert-DpDisk -DiskNumber 1 -DiskType MBR
Converts disk number 1 to MBR disk type.

.EXAMPLE
Convert-DpDisk -DiskNumber 2 -DiskType Dynamic
Converts disk number 2 to Dynamic disk type.
#>
Function Convert-DpDisk {
  [cmdletbinding()]
  param(
    [Int]
    [Parameter(ValueFromPipeline = $true,
      ValueFromPipelinebyPropertyName = $true,
      Mandatory = $true)]
    $DiskNumber,
    
    [ValidateSet('GPT', 'MBR', 'Dynamic', 'Basic')]
    $DiskType = 'GPT'
  )
  Process {
    $DiskpartCommand = @"
Select Disk $DiskNumber
Convert $DiskType
"@
    Write-Verbose $DiskpartCommand

    $DiskpartCommand | diskpart.exe
    Write-Verbose -Message $ReturnValue[-1]
  }
}