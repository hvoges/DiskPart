<#
.SYNOPSIS
Gets details of a VHD file using Diskpart.

.DESCRIPTION
The Get-DpVhdDetails function retrieves various details of a VHD (Virtual Hard Disk) file using Diskpart utility. It attaches the VHD file, retrieves disk and VHD information, and then detaches the VHD file.
For a less invasive way to retrieve VHD-Information, use Get-DPVhdInfo, which will also show the disk-chain of differencing disks.

.PARAMETER VHDPath
Specifies the path of the VHD file.

.EXAMPLE
Get-DpVhdDetails -VHDPath "C:\VHDs\Disk1.vhd"
This example retrieves the details of the VHD file located at "C:\VHDs\Disk1.vhd".

.NOTES
Author: Holger Voges
Date:   2024-01-18
#>

Function Get-DpVhdDetails
{
  param(
    [parameter(mandatory=$true)]
    [ValidateScript({ If  (-not ( Test-Path $_ -PathType Leaf ))
              { Throw "Die VHD-Datei existiert nicht" }
              $true
            })]
    [string]$VHDPath
  )

  $RegExKeyValue = '^(.+?)\s*:(?:\s*)?(.+)'
  $DiskpartCommand = @"
Select Vdisk FILE='$VHDPath'
Attach VDISK READONLY NODRIVELETTER
Det Disk
Det Vdisk
Detach VDisk
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