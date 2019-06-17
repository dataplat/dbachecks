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
    Step one. Get the free diskspace from the disks where Sql Server is parking it's files.
    The line will get the data from the chosen instance. Next the result is filtered down to just the drive letter for the summation later on.
    The -unique is used to limit the results. We get a result line for each database file, but all we need is a drive and the free space.

#>
try {
    $DiskFreeSpace = Get-DbaDbFile -SqlInstance $SqlInstance | Select-Object @{label='DriveLetter';Expression={$_.PhysicalName.substring(0,3)}}, VolumeFreeSpace, @{label='ComputerName';Expression={$env:COMPUTERNAME}} |Sort-Object -Property Driveletter -Unique
}
catch {
    Stop-PSFFunction -Message "There was a problem getting the free diskspace" -ErrorRecord $psitem
}
finally {
        Write-PSFMessage -Level Warning -Message "Execution was cancelled!"
        Pop-Location
}
<#
    Step two. Determine per drive letter how much growth can be expected.
    Same concept as the first step, but now we're looking at the file growth.
#>

try {
    $FileGrowth = Get-DbaDbFile -SqlInstance $SqlInstance | Select-Object @{label='DriveLetter';Expression={$_.PhysicalName.substring(0,3)}}, NextGrowthEventSize
}
catch {
    Stop-PSFFunction -Message "There was a problem getting the disk growth data" -ErrorRecord $psitem
}
finally {
        Write-PSFMessage -Level Warning -Message "Execution was cancelled!"
        Pop-Location
}
<#
    Step three, summation of the disk growth
#>


$calc = $FileGrowth | Group-Object -Property Driveletter | ForEach-Object -Process {
    $Sum = $_.group | Measure-Object -Sum -Property NextGrowthEventSize
    [pscustomobject]@{DriveLetter=$_.Name ; Value = [SqlCollaborative.Dbatools.Utility.Size]::new($Sum.sum)}
}

<#
    Step three and a bit, because the summation results in something else than GB, the result is rebuilt to gigabytes 
#>


# $CalcInGB = $calc | Select-Object DriveLetter, @{name="GrowthInGB" ; Expression={[math]::Round($_.value/1GB, 2)}}
# The above step is still alive for regression testing. 
<#
    Now for the interesting part. Time to compare the results!
    For each line in the disk free space results, the expected growth will be checked.
    If the drives are the same, the comparison will take place and the result will be shown.   
#>


$DiskFreeSpace | ForEach-Object -Process {
    if($_.DriveLetter -cin $Calc.DriveLetter)
    {
        $localDisk = $_.DriveLetter
        $localFileSize = $_.VolumeFreeSpace
        $computerName = $_.ComputerName
        $Calc | ForEach-Object -Process {
            If($_.DriveLetter -eq $localDisk)
            {
                if($_.GrowthInGB -ge  $localFileSize )
                {
                    Write-Host $localDisk 'Don't panic, don't Panic. Time to grow the this disk mr Mainwairing'
                    [PSCustomObject]@{Computer = $computerName ; SQLInstance = $SqlInstance ; DiskFreeSpace = $localFileSize ; Growth = $_.GrowthInGB ; GrowthAchievable = 'false'} 
                }
                else
                {
                    Write-Host $localDisk 'Fall in chaps, if you please... yes yes yes you look very smart'
                    [PSCustomObject]@{Computer = $computerName ; SQLInstance = $SqlInstance ; DiskFreeSpace = $localFileSize ; Growth = $_.GrowthInGB ; GrowthAchievable = 'true'}
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