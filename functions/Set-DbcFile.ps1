<#
.SYNOPSIS
Writes the result of Invoke-DbcCheck to a file (after converting with Convert-DbcResult)

.DESCRIPTION
When a check has been run with Invoke-DbcCheck (and -PassThru) and then converted with
Convert-DbcResult This command will write the results to a CSV, JSON or XML file

.PARAMETER InputObject
The datatable created by Convert-DbcResult

.PARAMETER FilePath
The directory for the file

.PARAMETER FileName
The name of the file

.PARAMETER FileType
The type of file -CSV,JSON,XML

.PARAMETER Append
Add to an existing file or not

.PARAMETER Force
Overwrite Existing file

.EXAMPLE
$Date = Get-Date -Format "yyyy-MM-dd"
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close_$Date -FileType xml

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to xml and saves in C:\temp\dbachecks\Auto-close_DATE.xml

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.xml -FileType xml

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to xml and saves in C:\temp\dbachecks\Auto-close.xml

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.csv -FileType csv

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to csv and saves in C:\temp\dbachecks\Auto-close.csv

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json -Append

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json appending the results to the existing file

.EXAMPLE
Invoke-DbcCheck -SqlInstance SQL2017N5 -Check AutoClose -Passthru | Convert-DbcResult -Label Beard-Check | Set-DbcFile -FilePath C:\temp\dbachecks\ -FileName Auto-close.json -FileType Json -Force

Runs the AutoClose check against SQL2017N5 and converts to a datatable with a label of Beard-Check and outputs to JSON and saves in C:\temp\dbachecks\Auto-close.json overwriting the existing file

.NOTES
Initial - RMS 28/12/2019
#>
function Set-DbcFile {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "Default")]
    [OutputType([string])]
    Param(
        # The pester results object
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Force')]
        $InputObject,
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        # The Directory for the file
        [string]$FilePath,
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        # The name for the file
        [string]$FileName,
        # the type of file
        [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        [ValidateSet('Csv', 'Json', 'Xml')]
        [string]$FileType,
        # Appending
        [Parameter(Mandatory = $true, ParameterSetName = 'Append')]
        [switch]$Append,
        # Overwrite file
        [Parameter(Mandatory = $true, ParameterSetName = 'Force')]
        [switch]$Force
    )

    Write-PSFMessage "Testing we have a Test Results object" -Level Verbose
    if(-not $InputObject){
        Write-PSFMessage "Uh-Oh - I'm really sorry - We don't have a Test Results Object" -Level Significant
        Write-PSFMessage "Did You forget the -PassThru parameter on Invoke-DbcCheck?" -Level Warning
        Return ''
    }
    Write-PSFMessage "Testing we can access $FilePath" -Level Verbose
    If (Test-Path -Path $FilePath) {

    }
    else {
        Write-PSFMessage "Uh-Oh - We cant access $FilePath - Please check that $Env:USERNAME has access" -Level Significant
        Return ''
    }
    $File = "$FilePath\$FileName"
    Write-PSFMessage "Testing if $file exists" -Level Verbose
    if (Test-Path -Path $file) {
        if (!$Force -and !$Append) {
            Write-PSFMessage "Uh-Oh - File $File exists - use the Force parameter to overwrite (even if your name is not Luke!)" -Level Significant
            Return ''
        }
        else {
            if (-not $Append) {
                Write-PSFMessage "File $File exists and will be overwritten " -Level Verbose
            }
        }
        if ($Append) {
            if ($FileType -eq 'XML') {
                Write-PSFMessage "I'm not coding appending to XML - Sorry - The Beard loves you but not that much" -Level Significant
                Return ''
            }
            else {
                Write-PSFMessage "File $File exists and will be appended to " -Level Verbose
            }
        }
    }

    function Add-Extension {
        Param ($FileType)
                if(-not ($FileName.ToLower().EndsWith(".$FileType"))){
                    Write-PSFMessage "No Extension supplied so I will add .$FileType to $Filename" -Level Verbose
                    $FileName = $FileName + '.' + $FileType
                }
                $File = "$FilePath\$FileName"
                $File
            }

    try {
        switch ($FileType) {
            'CSV' {
                $file = Add-Extension -FileType csv
                if ($PSCmdlet.ShouldProcess("$File" , "Adding results to CSV")) {
                    $InputObject  | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | Export-Csv -Path $File -NoTypeInformation -Append:$Append
                }
            }
            'Json' {
                $file = Add-Extension -FileType json
                if ($PSCmdlet.ShouldProcess("$File" , "Adding results to Json file")) {
                    $Date = @{Name = 'Date'; Expression = {($_.Date).Tostring('MM/dd/yy HH:mm:ss')}}
                    $InputObject  | Select-Object $Date, Label,Describe,Context,Name,Database,ComputerName,Instance,Result,FailureMessage | ConvertTo-Json | Out-File -FilePath $File -Append:$Append
                }
            }
            'Xml' {
                $file = Add-Extension -FileType xml
                if ($PSCmdlet.ShouldProcess("$File" , "Adding results to XML file ")) {
                    $InputObject  | Select-Object * -ExcludeProperty ItemArray, Table, RowError, RowState, HasErrors | Export-CliXml -Path $File -Force:$force
                }
            }
        }
        Write-PSFMessage "Exported results to $file" -Level Output
    }
    catch {
        Write-PSFMessage "Uh-Oh - We failed to create the file $file :-("
    }
}