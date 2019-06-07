function Get-DatabaseDiskFreeSpace {
    <#
    .SYNOPSIS
        Returns if there is enough diskspace for the instance to grow for one cycle.
        
    .DESCRIPTION
        Returns if there is enough diskspace for the instance to grow for one cycle.
        The checks is disk based, so the check will be done for each disk where the databases stores files.

    .NOTES
        Tags: Database, FileSize, FileGrowth
        Author: Reitse Eskens (@2meterDBA)

    .PARAMETER SqlInstance
        The Instance for which you want to perform your check
    
    .PARAMETER SqlCredential
        Credentials to connect to the SQL Server instance if the calling user doesn't have permission

    .EXAMPLE
        Get-DatabaseDiskFreeSpace -SqlInstance sql2016
    #>

[CmdletBinding()]

param (
        [parameter(ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential
       )


begin {
<#
    Step one. Get de free diskspace from the disks where Sql Server is parking it's files.
    The line will get the data from the chosen instance. Next the result is filtered down to just the drive letter for the summation later on.
    The -unique is used to limit the results. We get a result line for each database file, but all we need is a drive and the free space.

#>

$DiskFreeSpace = Get-DbaDbFile -SqlInstance REITSE-PC\VANTAGE | SELECT @{label='DriveLetter';Expression={$_.PhysicalName.substring(0,3)}}, VolumeFreeSpace |Sort-Object -Property Driveletter -Unique

<#
    Step two. Determine per drive letter how much growth can be expected.
    Same concept as the first step, but now we're looking at the file growth.
#>

$FileGrowth = Get-DbaDbFile -SqlInstance REITSE-PC\VANTAGE | SELECT @{label='DriveLetter';Expression={$_.PhysicalName.substring(0,3)}}, NextGrowthEventSize

<#
    Step three, summation of the disk growth
#>


$calc = $FileGrowth | Group-Object -Property Driveletter | ForEach-Object -Process {
    $Sum = $_.group | measure -Sum -Property NextGrowthEventSize
    [pscustomobject]@{DriveLetter=$_.Name ; value = $Sum.Sum}
}

<#
    Step three and a bit, because the summation results in something else than GB, the result is rebuilt to gigabytes 
#>


$CalcInGB = $calc | select DriveLetter, @{name="GrowthInGB" ; Expression={[math]::Round($_.value/1GB, 2)}}

<#
    Now for the interesting part. Time to compare the results!
    For each line in the disk free space results, the expected growth will be checked.
    If the drives are the same, the comparison will take place and the result will be shown.   
#>


$DiskFreeSpace | ForEach-Object -Process {
    if($_.DriveLetter -cin $CalcInGB.DriveLetter)
    {
        $localDisk = $_.DriveLetter
        $localFileSize = $_.VolumeFreeSpace
        $CalcInGB | ForEach-Object -Process {
            If($_.DriveLetter -eq $localDisk)
            {
                if($_.GrowthInGB -ge  $localFileSize )
                {
                    Write-Host $localDisk 'Don't panic, don't Panic. Time to grow the this disk mr Mainwairing'
                }
                else
                {
                    Write-Host $localDisk 'Fall in chaps, if you please... yes yes yes you look very smart'
                }
            
            }
          }
    }
    else
    {
        Write-Host $_.DriveLetter 'Pike! You stupid Boy!'
    }
   }
  }
}