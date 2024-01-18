<#
.SYNOPSIS
Creates a new disk partition using Diskpart.

.DESCRIPTION
The New-DpVolume function creates a new disk partition using Diskpart utility. It allows you to specify the disk number, partition type, partition size, and drive letter.

.PARAMETER DiskNumber
The disk number on which the partition will be created.

.PARAMETER Type
The type of the partition. Valid values are 'Primary', 'EFI', 'MSR', 'Extended', and 'Logical'.

.PARAMETER PartitionSize
The size of the partition in bytes.

.PARAMETER Driveletter
The drive letter to assign to the partition.

.EXAMPLE
New-DpVolume -DiskNumber 1 -Type Primary -PartitionSize 1073741824 -Driveletter 'D'
Creates a new primary partition with a size of 1 GB and assigns the drive letter 'D' to it on disk number 1.

.NOTES
This function requires administrative privileges to run.
#>
Function New-DpVolume
{
  [cmdletbinding()]
  param
  (
    [Int]
    [Parameter(ValueFromPipelinebyPropertyName=$true,
               Mandatory=$true)]
    $DiskNumber,
   
    [ValidateSet('Primary','EFI','MSR','Extended','Logical')]
    $Type = 'Primary',
    
    [int]
    $PartitionSize,
    
    [ValidatePattern('^([C-Zc-z]:?)$')]
    [String]$Driveletter
  )
  
  If ( $Driveletter )
  {
    If ( $DriveLetter.Length -eq 2 )
    {
      $DriveLetter = $DriveLetter.Substring(0,1)
    }
    $AssignLetter = 'Assign Letter = {0}' -f $Driveletter  
  }
  
  
  if ( $PartitionSize )
  {
    $size = $PartitionSize / 1MB
    $SizeArgument = 'Size={0}' -f $size
  }
  ElseIf ( $type -eq "EFI" )
    { $SizeArgument = 'Size=100' }
  ElseIf ( $type -eq "MSR" )
    { $SizeArgument = 'Size=128' }
  Write-Verbose $PartitionSize
  
  
  Switch ( $Type )
  {
    'Primary' { $parameter = "PRIMARY $SizeArgument"}
    'EFI' { $parameter = "EFI $SizeArgument" }
    'MSR' { $parameter = "MSR $SizeArgument" }
    'Extended' { $parameter = "Extended $SizeArgument"}
    'Logical' { $parameter = "Logical $SizeArgument" }
  }
  Write-Verbose $parameter
  
      $DiskpartCommand = @"
Select Disk $DiskNumber
create Partition $parameter 
$AssignLetter
"@
  Write-Verbose $DiskpartCommand

  $ReturnValue = $DiskpartCommand | diskpart.exe
  Write-Verbose -Message $ReturnValue[-1]
    
}