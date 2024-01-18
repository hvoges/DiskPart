<#
.SYNOPSIS
Merges a differencing VHD to its parent VHD using Diskpart.

.DESCRIPTION
The Merge-DpVhdDiffToParent function merges a differencing VHD to its parent VHD using Diskpart. It takes the path of the VHD file as a mandatory parameter and performs the merge operation using Diskpart commands.

.PARAMETER VHDPath
The path of the Differencing VHD file to be merged. This parameter is mandatory.

.EXAMPLE
Merge-DpVhdDiffToParent -VHDPath "C:\VHDs\diff.vhd"
Merges the differencing VHD file "C:\VHDs\diff.vhd" to its parent VHD using Diskpart.

.NOTES
Author: Your Name
Date: Current Date
#>
Function Merge-DpVhdDiffToParent 
{
  param(
    [parameter(mandatory=$true)]
    [ValidateScript({ If  ( -not ( Test-Path $_ -PathType Leaf ))
              { Throw "Die VHD-Datei existiert nicht" }
              $true
            })]
    [string]$VHDPath
  )
  
  $VHDFile = Get-ChildItem $VHDPath -Force
  $DiskPartCommand = @"
Select Vdisk file=$VHDPath
Merge VDISK Depth=1
"@
  $DiskPartCommand | diskpart.exe 
}