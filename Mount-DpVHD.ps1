<#
.SYNOPSIS
Mounts a VHD file and returns information about the mounted volume.

.DESCRIPTION
The Mount-DpVHD function mounts a VHD (Virtual Hard Disk) file and retrieves information about the mounted volume. It uses diskpart.exe to execute the necessary commands.

.PARAMETER VhdFile
Specifies the path to the VHD file that needs to be mounted.

.EXAMPLE
Mount-DpVHD -VhdFile "C:\Path\to\VHD.vhd"
Mounts the specified VHD file and returns information about the mounted volume.

.NOTES
Author: Your Name
Date: Current Date
Version: 1.0
#>
Function Mount-DpVHD {
  param(
    [ValidateScript({ if ( -not (test-path -Path $_ -PathType leaf ))
        { Throw "Bitte prüfen Sie den Pfad. Die Datei existiert nicht" }
        $true
      })]
    [parameter(mandatory = $true)]
    [string]$VhdFile
  )

  [Regex]$RegEx = 'Volume\s*(\d*)\s*(.)\s*(\w*)\s*(\w*)\s*(\w*)\s*(\d*\s*\wB)\s*(\w*)\s*(\w*)'
  
  $VdiskCommandList = @"
Select vdisk file='$VhdFile'
Attach Vdisk
Det Disk
"@
  
  $ReturnValue = $VdiskCommandList | diskpart.exe
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
      New-Object -TypeName PsCustomObject -Property $volume
    }
  }  
  Write-Verbose -Message $ReturnValue[0]
}

# mount-dpvhd : Laufwerksbuchstaben zurückgeben
# bcdboot als Skript