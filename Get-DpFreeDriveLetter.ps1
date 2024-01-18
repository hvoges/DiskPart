<#
.SYNOPSIS
    This function returns the first available drive letter starting from a specified letter.

.DESCRIPTION
    The Get-FreeDriveLetter function checks for the availability of drive letters starting from a specified letter (default is 'C'). It iterates through the ASCII character codes from the specified letter to 'Z' and checks if each letter is already assigned to a drive. Once it finds an available drive letter, it returns that letter.

.PARAMETER Startletter
    Specifies the letter from which the search for available drive letters should start. The default value is 'C'.

.EXAMPLE
    Get-FreeDriveLetter
    Returns the first available drive letter starting from 'C'.

.EXAMPLE
    Get-FreeDriveLetter -Startletter 'D'
    Returns the first available drive letter starting from 'D'.

#>

Function Get-DpFreeDriveLetter {
    param( 
        [Byte][Char]$Startletter = 'C' 
    )

    [int]$Counter = $Startletter
    $Chararray = $Counter..90 
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ( $letter in $CharArray ) {
        if ( [Char]$letter -notin $drives.Name ) {
            [char]$letter
            break
        }
    }
}
