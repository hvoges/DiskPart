<#
.SYNOPSIS
Creates a differential VHD file based on a parent VHD file.

.DESCRIPTION
The New-DpVhdDiff function creates a differential VHD file (.vhd) based on a parent VHD file. 
The function takes the path of the parent VHD file as a mandatory parameter and an optional 
parameter to specify the naming pattern for the differential VHD file.

.PARAMETER VHDPath
Specifies the path of the parent VHD file. This parameter is mandatory.

.PARAMETER DiffPattern
Specifies the naming pattern for the differential VHD file. The default value is "_Diff".

.EXAMPLE
New-DpVhdDiff -VHDPath "C:\ParentVHD.vhd" -DiffPattern "_Diff"
Creates a differential VHD file named "ParentVHD_Diff.vhd" based on the parent VHD file located at "C:\ParentVHD.vhd".

.NOTES
Author: Holger Voges
Date: 2024-01-18
#>
Function New-DpVhdDiff {
  param(
    [parameter(mandatory = $true)]
    [ValidateScript({ If ( -not ( Test-Path $_ -PathType Leaf ))
        { Throw "Die VHD-Datei existiert nicht" }
        $true
      })]
    [string]$VHDPath,

    [string]$DiffPattern = "_Diff"
  )
    
  $VHDFile = Get-ChildItem $VHDPath -Force
  $DiffFile = Join-Path -Path $VHDFile.Directory -ChildPath ($VhdFile.BaseName + $DiffPattern + $VHDFile.Extension)
  $DiskPartCommand = @"
CREATE VDISK FILE='$DiffFile' PARENT='$VhdPath'
"@
  $ReturnValue = $DiskPartCommand | diskpart.exe 
  Write-Verbose -Message $ReturnValue[-1]
  $DiffObject = New-Object PSCustomObject -Property @{ VHDPath = $DiffFile }
  # Return Object for Piping into New-BCDEntry
  $DiffObject
}