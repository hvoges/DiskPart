<#
.SYNOPSIS
Retrieves detailed information about a disk using Diskpart.

.DESCRIPTION
The Get-DpDiskDetails function retrieves detailed information about a disk using Diskpart utility. It takes the DiskNumber as a parameter and returns an object containing various disk attributes.

.PARAMETER DiskNumber
Specifies the disk number for which to retrieve the details.

.EXAMPLE
Get-DpDiskDetails -DiskNumber 0
Retrieves detailed information about disk number 0.

.NOTES
Author: Your Name
Date: 2024-01-18
#>

Function Get-DpDiskDetails
{
  param(
    [parameter(mandatory=$true,
               ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true)]
    [Alias('ID','DiskID')]
    [int]$DiskNumber
  )
  
  Process {
    $RegExKeyValue = '^(.+?)\s*:(?:\s*)?(.+)'
    $DiskpartCommand = @"
Select Disk $DiskID
Det Disk
"@
    $ReturnValue = $DiskpartCommand | diskpart.exe 
    $DiskAttributes = [ordered]@{}
    Foreach ( $Line in $ReturnValue )
    {
        If ( $line -match $RegExKeyValue )
        {
            $DiskAttributes[$matches[1]] = $matches[2] 
        }
    }
    [PSCustomObject]$diskAttributes
  }
}